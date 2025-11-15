// Delete device route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::application::use_cases::delete_device::DeleteDeviceUseCase;
use crate::features::auth::domain::entities::Claims;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::token_service::TokenService;
use crate::features::auth::structs::models::TokenCache;
use crate::features::profile::application::dto::requests::DeleteDeviceParams;
use crate::features::profile::application::dto::responses::DeviceDeleteResponse;
use actix_web::web::{Data, Path, ReqData};
use actix_web::{delete, HttpResponse, Responder};
use redis::Client;
use sqlx::PgPool;
use tracing::error;

#[delete("/{token_id}")]
pub async fn delete_device(
    claims: ReqData<Claims>,
    pool: Data<PgPool>,
    params: Path<DeleteDeviceParams>,
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
    let delete_device_use_case = DeleteDeviceUseCase::new(token_repo);

    // Execute use case
    let result = delete_device_use_case
        .execute(claims.user_id, params.token_id, &mut transaction)
        .await;

    // Remove from cache
    cached_tokens.remove_key(claims.jti).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => {
            // Publish Redis event
            let token_service = TokenService::new(redis_client);
            if let Err(e) = token_service
                .publish_token_removed_event(params.token_id, claims.user_id)
                .await
            {
                error!("Error publishing token removed event: {}", e);
            }

            HttpResponse::Ok().json(DeviceDeleteResponse {
                code: "DEVICE_DELETED".to_string(),
            })
        }
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
