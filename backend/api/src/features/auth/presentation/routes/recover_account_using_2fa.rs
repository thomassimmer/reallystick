// Recover account using 2FA route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::application::dto::requests::RecoverAccountUsing2FARequest;
use crate::features::auth::application::dto::responses::UserLoginResponse;
use crate::features::auth::application::use_cases::generate_tokens::GenerateTokensUseCase;
use crate::features::auth::application::use_cases::recover_account_using_2fa::RecoverAccountUsing2FAUseCase;
use crate::features::auth::infrastructure::repositories::recovery_code_repository::RecoveryCodeRepositoryImpl;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::token_service::TokenService;
use crate::features::profile::helpers::device_info::get_user_agent;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json};
use actix_web::{post, HttpRequest, HttpResponse, Responder};
use redis::Client;
use sqlx::PgPool;
use tracing::error;

#[post("/recover-using-2fa")]
pub async fn recover_account_using_2fa(
    req: HttpRequest,
    body: Json<RecoverAccountUsing2FARequest>,
    pool: Data<PgPool>,
    secret: Data<String>,
    redis_client: Data<Client>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let body = body.into_inner();

    // Create repositories and services
    let pool_clone = pool.get_ref().clone();
    let user_repo = UserRepositoryImpl::new(pool_clone.clone());
    let recovery_code_repo = RecoveryCodeRepositoryImpl::new(pool_clone.clone());
    let token_repo = UserTokenRepositoryImpl::new(pool_clone.clone());
    let _token_service = TokenService::new(redis_client.clone());

    // Execute recover account use case
    let recover_account_use_case =
        RecoverAccountUsing2FAUseCase::new(user_repo, recovery_code_repo, token_repo);
    let (user, private_key_encrypted, salt_used_to_derive_key) = match recover_account_use_case
        .execute(
            body.username.clone(),
            body.code.clone(),
            body.recovery_code.clone(),
            &mut transaction,
        )
        .await
    {
        Ok(result) => result,
        Err(AppError::UserHasBeenDeleted) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::Unauthorized().json(AppError::UserHasBeenDeleted.to_response());
        }
        Err(AppError::TwoFactorAuthenticationNotEnabled) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::Forbidden()
                .json(AppError::TwoFactorAuthenticationNotEnabled.to_response());
        }
        Err(AppError::InvalidUsernameOrCodeOrRecoveryCode) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::Unauthorized()
                .json(AppError::InvalidUsernameOrCodeOrRecoveryCode.to_response());
        }
        Err(e) => {
            error!("Error: {:?}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(e.to_response());
        }
    };

    // Generate tokens - create new instances since we moved the old ones
    let pool_clone = pool.get_ref().clone();
    let token_repo_for_tokens = UserTokenRepositoryImpl::new(pool_clone.clone());
    let token_service_for_tokens = TokenService::new(redis_client.clone());
    let parsed_device_info = get_user_agent(req).await;
    let generate_tokens_use_case =
        GenerateTokensUseCase::new(token_repo_for_tokens, token_service_for_tokens);
    let (access_token, refresh_token) = match generate_tokens_use_case
        .execute(
            secret.as_bytes(),
            user.clone(),
            parsed_device_info,
            &mut transaction,
        )
        .await
    {
        Ok(tokens) => tokens,
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError()
                .json(AppError::TokenGeneration.to_response());
        }
    };

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(UserLoginResponse {
        code: "USER_LOGGED_IN_AFTER_ACCOUNT_RECOVERY".to_string(),
        access_token,
        refresh_token,
        public_key: user.public_key,
        private_key_encrypted: Some(private_key_encrypted),
        salt_used_to_derive_key: Some(salt_used_to_derive_key),
    })
}
