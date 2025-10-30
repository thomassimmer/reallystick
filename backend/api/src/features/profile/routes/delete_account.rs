use crate::{
    core::{
        constants::errors::AppError, helpers::mock_now::now,
        structs::redis_messages::UserRemovedEvent,
    },
    features::{
        auth::{helpers::token::delete_user_tokens, structs::models::Claims},
        profile::{
            helpers::profile::update_user_deleted_at, structs::responses::DeleteAccountResponse,
        },
    },
};
use actix_web::{
    delete,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
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

    let delete_result =
        update_user_deleted_at(&mut *transaction, request_claims.user_id, Some(now())).await;

    if let Err(e) = delete_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response());
    }

    // Delete immediately all user tokens
    let delete_result = delete_user_tokens(request_claims.user_id, &mut *transaction).await;

    if let Err(e) = delete_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::UserTokenDeletion.to_response());
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

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
