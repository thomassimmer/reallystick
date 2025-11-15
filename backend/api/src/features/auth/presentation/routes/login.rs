// Login route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::core::structs::responses::GenericResponse;
use crate::features::auth::application::dto::requests::UserLoginRequest;
use crate::features::auth::application::dto::responses::{
    UserLoginResponse, UserLoginWhenOtpEnabledResponse,
};
use crate::features::auth::application::use_cases::login::LoginUseCase;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::token_service::TokenService;
use crate::features::profile::helpers::device_info::get_user_agent;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json};
use actix_web::{post, HttpRequest, HttpResponse, Responder};
use redis::Client;
use sqlx::PgPool;
use tracing::error;

#[post("/login")]
pub async fn log_user_in(
    req: HttpRequest,
    body: Json<UserLoginRequest>,
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

    // Create repositories and services
    let pool_clone = pool.get_ref().clone();
    let user_repo = UserRepositoryImpl::new(pool_clone.clone());
    let token_repo = UserTokenRepositoryImpl::new(pool_clone.clone());
    let token_service = TokenService::new(redis_client.clone());
    let login_use_case = LoginUseCase::new(user_repo, token_repo, token_service);

    // Get device info
    let parsed_device_info = get_user_agent(req).await;

    // Execute use case
    let result = login_use_case
        .execute(
            body.username.clone(),
            body.password.clone(),
            secret.as_bytes(),
            parsed_device_info,
            &mut transaction,
        )
        .await;

    // Handle OTP case - check before committing transaction
    if let Err(e) = &result {
        if let Some(user_json) = e.strip_prefix("OTP_ENABLED:") {
            // Parse user from error string
            if let Ok(user) =
                serde_json::from_str::<crate::features::profile::domain::entities::User>(user_json)
            {
                if let Err(e) = transaction.rollback().await {
                    error!("Error rolling back: {}", e);
                }
                return HttpResponse::Ok().json(UserLoginWhenOtpEnabledResponse {
                    code: "USER_LOGS_IN_WITH_OTP_ENABLED".to_string(),
                    user_id: user.id.to_string(),
                    public_key: user.public_key,
                    private_key_encrypted: user.private_key_encrypted,
                    salt_used_to_derive_key: user.salt_used_to_derive_key_from_password,
                });
            }
        }
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok((user, access_token, refresh_token)) => HttpResponse::Ok().json(UserLoginResponse {
            code: "USER_LOGGED_IN_WITHOUT_OTP".to_string(),
            access_token,
            refresh_token,
            public_key: user.public_key,
            private_key_encrypted: user.private_key_encrypted,
            salt_used_to_derive_key: user.salt_used_to_derive_key_from_password,
        }),
        Err(e) => {
            error!("Error: {}", e);
            if e == "PASSWORD_MUST_BE_CHANGED" {
                return HttpResponse::Forbidden().json(GenericResponse {
                    code: "PASSWORD_MUST_BE_CHANGED".to_string(),
                    message: "Password must be changed".to_string(),
                });
            }
            if e == "User has been deleted" {
                return HttpResponse::Unauthorized()
                    .json(AppError::UserHasBeenDeleted.to_response());
            }
            HttpResponse::Unauthorized().json(AppError::InvalidUsernameOrPassword.to_response())
        }
    }
}
