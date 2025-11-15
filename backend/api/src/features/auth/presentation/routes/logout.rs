// Logout route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::core::structs::responses::GenericResponse;
use crate::features::auth::application::use_cases::logout::LogoutUseCase;
use crate::features::auth::domain::entities::Claims;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::token_service::TokenService;
use crate::features::auth::structs::models::TokenCache;
use actix_web::web::{Data, ReqData};
use actix_web::{get, HttpResponse, Responder};
use redis::Client;
use sqlx::PgPool;
use tracing::error;

#[get("")]
pub async fn log_user_out(
    request_claims: ReqData<Claims>,
    pool: Data<PgPool>,
    redis_client: Data<Client>,
    cached_tokens: Data<TokenCache>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repository and use case
    let pool_clone = pool.get_ref().clone();
    let token_repo = UserTokenRepositoryImpl::new(pool_clone);
    let logout_use_case = LogoutUseCase::new(token_repo);

    // Execute use case
    let result = logout_use_case
        .execute(request_claims.jti, &mut transaction)
        .await;

    if let Err(e) = result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    // Remove token from cache
    cached_tokens.remove_key(request_claims.jti).await;

    // Publish token removed event
    let token_service = TokenService::new(redis_client.clone());
    if let Err(e) = token_service
        .publish_token_removed_event(request_claims.jti, request_claims.user_id)
        .await
    {
        error!("Error publishing token removal: {}", e);
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(GenericResponse {
        code: "LOGGED_OUT".to_string(),
        message: "".to_string(),
    })
}
