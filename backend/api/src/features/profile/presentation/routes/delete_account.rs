// Delete account route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::core::structs::redis_messages::UserRemovedEvent;
use crate::features::auth::domain::entities::Claims;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::profile::application::dto::responses::DeleteAccountResponse;
use crate::features::profile::application::use_cases::delete_account::DeleteAccountUseCase;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, ReqData};
use actix_web::{delete, HttpResponse, Responder};
use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;

#[delete("/me")]
pub async fn delete_account(
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

    // Create repositories and use case
    let pool_clone = pool.get_ref().clone();
    let user_repo = UserRepositoryImpl::new(pool_clone.clone());
    let token_repo = UserTokenRepositoryImpl::new(pool_clone.clone());
    let delete_account_use_case = DeleteAccountUseCase::new(user_repo, token_repo);

    // Execute use case
    let result = delete_account_use_case
        .execute(request_claims.user_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => {
            // Publish Redis event
            match redis_client.get_multiplexed_async_connection().await {
                Ok(mut con) => {
                    let result: Result<(), redis::RedisError> = con
                        .publish(
                            "user_marked_as_deleted",
                            json!(UserRemovedEvent {
                                user_id: request_claims.user_id,
                            })
                            .to_string(),
                        )
                        .await;
                    if let Err(e) = result {
                        error!("Error: {}", e);
                    }
                }
                Err(e) => {
                    error!("Error: {}", e);
                }
            }

            HttpResponse::Ok().json(DeleteAccountResponse {
                code: "ACCOUNT_DELETED".to_string(),
            })
        }
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
