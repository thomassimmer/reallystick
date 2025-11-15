// Validate OTP route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::core::structs::responses::GenericResponse;
use crate::features::auth::application::dto::requests::ValidateOtpRequest;
use crate::features::auth::application::dto::responses::UserLoginResponse;
use crate::features::auth::application::use_cases::generate_tokens::GenerateTokensUseCase;
use crate::features::auth::application::use_cases::validate_otp::ValidateOtpUseCase;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::token_service::TokenService;
use crate::features::profile::helpers::device_info::get_user_agent;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json};
use actix_web::{post, HttpRequest, HttpResponse, Responder};
use redis::Client;
use sqlx::PgPool;
use tracing::error;

#[post("/validate")]
pub async fn validate(
    req: HttpRequest,
    body: Json<ValidateOtpRequest>,
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
    let user_id = body.user_id;

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let user_repo = UserRepositoryImpl::new(pool_clone.clone());
    let token_repo = UserTokenRepositoryImpl::new(pool_clone.clone());
    let token_service = TokenService::new(redis_client.clone());

    // Validate OTP
    let validate_otp_use_case = ValidateOtpUseCase::new(user_repo);
    let user = match validate_otp_use_case
        .execute(user_id, body.code.clone(), &mut transaction)
        .await
    {
        Ok(user) => user,
        Err(AppError::TwoFactorAuthenticationNotEnabled) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::Forbidden()
                .json(AppError::TwoFactorAuthenticationNotEnabled.to_response());
        }
        Err(AppError::InvalidOneTimePassword) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::Unauthorized()
                .json(AppError::InvalidOneTimePassword.to_response());
        }
        Err(AppError::UserNotFound) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(GenericResponse {
                code: "USER_NOT_FOUND".to_string(),
                message: format!("No user with id {} found", user_id),
            });
        }
        Err(e) => {
            error!("Error: {:?}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(e.to_response());
        }
    };

    // Generate tokens
    let parsed_device_info = get_user_agent(req).await;
    let generate_tokens_use_case = GenerateTokensUseCase::new(token_repo, token_service);
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
        code: "USER_LOGGED_IN_AFTER_OTP_VALIDATION".to_string(),
        access_token,
        refresh_token,
        public_key: user.public_key,
        private_key_encrypted: user.private_key_encrypted,
        salt_used_to_derive_key: user.salt_used_to_derive_key_from_password,
    })
}
