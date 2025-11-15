// Set FCM token route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::core::structs::responses::GenericResponse;
use crate::features::auth::application::use_cases::set_fcm_token::SetFcmTokenUseCase;
use crate::features::auth::domain::entities::Claims;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::token_service::TokenService;
use crate::features::profile::application::dto::requests::SetFcmTokenRequest;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
use redis::Client;
use sqlx::PgPool;
use tracing::error;

#[post("/save-fcm-token")]
pub async fn set_fcm_token(
    body: Json<SetFcmTokenRequest>,
    pool: Data<PgPool>,
    redis_client: Data<Client>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let user_repo = UserRepositoryImpl::new(pool_clone.clone());
    let token_repo = UserTokenRepositoryImpl::new(pool_clone.clone());

    // Execute use case
    let set_fcm_token_use_case = SetFcmTokenUseCase::new(user_repo, token_repo);
    let result = set_fcm_token_use_case
        .execute(
            request_claims.user_id,
            request_claims.jti,
            body.fcm_token.clone(),
            &mut transaction,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok((user, token)) => {
            // Publish Redis event
            let token_service = TokenService::new(redis_client);
            if let Err(e) = token_service
                .publish_token_updated_event(token.clone(), user.clone())
                .await
            {
                error!("Error publishing token updated event: {}", e);
            }

            HttpResponse::Ok().json(GenericResponse {
                code: "FCM_TOKEN_UPDATED".to_string(),
                message: "Your fcm token was saved".to_string(),
            })
        }
        Err(AppError::UserTokenNotFound) => {
            HttpResponse::NotFound().json(AppError::UserTokenNotFound.to_response())
        }
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
