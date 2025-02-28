use crate::{
    core::{constants::errors::AppError, structs::redis_messages::UserTokenRemovedEvent},
    features::{
        auth::{
            helpers::token::{delete_token, get_user_token},
            structs::models::{Claims, TokenCache},
        },
        profile::structs::{requests::DeleteDeviceParams, responses::DeviceDeleteResponse},
    },
};
use actix_web::{
    delete,
    web::{Data, Path, ReqData},
    HttpResponse, Responder,
};
use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::PgPool;

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
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let token = get_user_token(claims.user_id, params.token_id, &mut *transaction).await;

    match token {
        Ok(r) => {
            if r.is_none() {
                return HttpResponse::InternalServerError()
                    .json(AppError::DatabaseQuery.to_response());
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let result_delete_token = delete_token(params.token_id, &mut *transaction).await;

    if let Err(e) = result_delete_token {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
    }

    cached_tokens.remove_key(claims.jti).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match redis_client.get_multiplexed_async_connection().await {
        Ok(mut con) => {
            let result: Result<(), redis::RedisError> = con
                .publish(
                    "user_token_removed",
                    json!(UserTokenRemovedEvent {
                        token_id: params.token_id,
                        user_id: claims.user_id,
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

    HttpResponse::Ok().json(DeviceDeleteResponse {
        code: "DEVICE_DELETED".to_string(),
    })
}
