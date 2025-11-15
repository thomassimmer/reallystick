// Refresh token route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::core::structs::responses::GenericResponse;
use crate::features::auth::application::dto::requests::RefreshTokenRequest;
use crate::features::auth::application::dto::responses::RefreshTokenResponse;
use crate::features::auth::application::use_cases::refresh_token::RefreshTokenUseCase;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::token_service::TokenService;
use crate::features::profile::helpers::device_info::get_user_agent;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json};
use actix_web::{post, HttpRequest, HttpResponse, Responder};
use redis::Client;
use sqlx::PgPool;
use tracing::error;

#[post("/refresh-token")]
pub async fn refresh_token(
    req: HttpRequest,
    body: Json<RefreshTokenRequest>,
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

    // Validate token and get claims
    let claims = match token_service.validate_token(&body.refresh_token, secret.as_bytes()) {
        Ok(c) => c,
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::Unauthorized().json(AppError::InvalidRefreshToken.to_response());
        }
    };

    // Create use case after validation
    let refresh_token_use_case = RefreshTokenUseCase::new(token_repo, token_service);

    // Get user
    let user = match user_repo
        .get_by_id_with_executor(claims.user_id, &mut *transaction)
        .await
    {
        Ok(Some(u)) => u,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::Unauthorized().json(AppError::UserNotFound.to_response());
        }
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseTransaction.to_response());
        }
    };

    // Get device info
    let parsed_device_info = get_user_agent(req).await;

    // Execute use case
    let result = refresh_token_use_case
        .execute(
            body.refresh_token.clone(),
            secret.as_bytes(),
            user,
            parsed_device_info,
            &mut transaction,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok((access_token, refresh_token, _jti)) => HttpResponse::Ok().json(RefreshTokenResponse {
            code: "TOKEN_REFRESHED".to_string(),
            access_token,
            refresh_token,
        }),
        Err(e) => {
            error!("Error: {}", e);
            if e == "REFRESH_TOKEN_EXPIRED" {
                return HttpResponse::Unauthorized().json(GenericResponse {
                    code: "REFRESH_TOKEN_EXPIRED".to_string(),
                    message: "Refresh token expired".to_string(),
                });
            }
            HttpResponse::Unauthorized().json(AppError::InvalidRefreshToken.to_response())
        }
    }
}
