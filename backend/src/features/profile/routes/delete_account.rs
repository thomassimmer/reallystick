use crate::{
    core::{constants::errors::AppError, structs::redis_messages::UserRemovedEvent},
    features::{
        auth::structs::models::Claims,
        profile::{helpers::profile::delete_user_by_id, structs::responses::DeleteAccountResponse},
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

#[delete("/me")]
pub async fn delete_account(
    pool: Data<PgPool>,
    redis_client: Data<Client>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let delete_result = delete_user_by_id(&mut transaction, request_claims.user_id).await;

    if let Err(e) = delete_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response());
    }

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match redis_client.get_multiplexed_async_connection().await {
        Ok(mut con) => {
            let result: Result<(), redis::RedisError> = con
                .publish(
                    "user_removed",
                    json!(UserRemovedEvent {
                        user_id: request_claims.user_id,
                    })
                    .to_string(),
                )
                .await;
            if let Err(e) = result {
                eprintln!("Error: {}", e);
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
        }
    }

    return HttpResponse::Ok().json(DeleteAccountResponse {
        code: "ACCOUNT_DELETED".to_string(),
    });
}
