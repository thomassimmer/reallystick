use crate::core::constants::errors::AppError;
use crate::core::structs::redis_messages::UserTokenRemovedEvent;
use crate::core::structs::responses::GenericResponse;
use crate::features::auth::helpers::token::delete_token;
use crate::features::auth::structs::models::{Claims, TokenCache};
use actix_web::web::ReqData;
use actix_web::{get, web, HttpResponse, Responder};
use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;

#[get("")]
pub async fn log_user_out(
    request_claims: ReqData<Claims>,
    pool: web::Data<PgPool>,
    cached_tokens: web::Data<TokenCache>,
    redis_client: web::Data<Client>,
) -> impl Responder {
    if let Err(e) = delete_token(request_claims.jti, &**pool).await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    cached_tokens.remove_key(request_claims.jti).await;

    match redis_client.get_multiplexed_async_connection().await {
        Ok(mut con) => {
            let result: Result<(), redis::RedisError> = con
                .publish(
                    "user_token_removed",
                    json!(UserTokenRemovedEvent {
                        token_id: request_claims.jti,
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

    HttpResponse::Ok().json(GenericResponse {
        code: "LOGGED_OUT".to_string(),
        message: "".to_string(),
    })
}
