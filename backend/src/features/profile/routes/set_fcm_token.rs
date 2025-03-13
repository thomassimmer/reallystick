use crate::{
    core::{
        constants::errors::AppError,
        structs::{redis_messages::UserTokenRemovedEvent, responses::GenericResponse},
    },
    features::{
        auth::{
            helpers::token::{get_user_token, update_token},
            structs::models::Claims,
        },
        profile::structs::requests::SetFcmTokenRequest,
    },
};
use actix_web::{
    post,
    web::{Data, Json, ReqData},
    HttpResponse, Responder,
};
use redis::{AsyncCommands, Client};
use serde_json::json;
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

    let existing_token = get_user_token(
        request_claims.user_id,
        request_claims.jti,
        &mut *transaction,
    )
    .await;

    let mut token = match existing_token {
        Ok(r) => match r {
            Some(token) => token,
            None => {
                return HttpResponse::NotFound().json(AppError::UserTokenNotFound.to_response());
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    token.fcm_token = body.fcm_token.clone();

    let updated_token_result = update_token(token.clone(), &mut *transaction).await;

    if let Err(e) = updated_token_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response());
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
                    "user_token_updated",
                    json!(UserTokenRemovedEvent {
                        token_id: token.id,
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

    return HttpResponse::Ok().json(GenericResponse {
        code: "FCM_TOKEN_UPDATED".to_string(),
        message: "Your fcm token was saved".to_string(),
    });
}
