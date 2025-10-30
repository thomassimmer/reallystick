use crate::{
    core::{
        constants::errors::AppError,
        helpers::mock_now::now,
        structs::{
            redis_messages::{UserTokenRemovedEvent, UserTokenUpdatedEvent},
            responses::GenericResponse,
        },
    },
    features::{
        auth::{
            helpers::token::{
                delete_token, generate_access_token, generate_refresh_token, save_tokens,
            },
            structs::{
                models::{Claims, TokenCache}, requests::RefreshTokenRequest, responses::RefreshTokenResponse,
            },
        },
        profile::helpers::{device_info::get_user_agent, profile::get_user_by_id},
    },
};
use actix_web::{post, web, HttpRequest, HttpResponse, Responder};
use jsonwebtoken::{decode, DecodingKey, Validation};
use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/refresh-token")]
pub async fn refresh_token(
    req: HttpRequest,
    body: web::Json<RefreshTokenRequest>,
    pool: web::Data<PgPool>,
    secret: web::Data<String>,
    cached_tokens: web::Data<TokenCache>,
    redis_client: web::Data<Client>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let refresh_token = body.refresh_token.clone();

    let decoding_key = DecodingKey::from_secret(secret.as_bytes());
    let token_data = decode::<Claims>(&refresh_token, &decoding_key, &Validation::default());

    if let Err(e) = token_data {
        error!("Error: {}", e);
        return HttpResponse::Unauthorized().json(AppError::InvalidRefreshToken.to_response());
    }

    let claims = token_data.unwrap().claims;

    // Check if the refresh token exists in the database
    let stored_token = sqlx::query_scalar!(
        r#"
        SELECT expires_at
        FROM user_tokens
        WHERE token_id = $1
        "#,
        claims.jti
    )
    .fetch_optional(&mut *transaction)
    .await;

    match stored_token {
        Ok(Some(expires_at)) => {
            if now() > expires_at {
                // Remove user session / token
                if let Err(e) = delete_token(claims.jti, &mut *transaction).await {
                    error!("Error: {}", e);
                    return HttpResponse::InternalServerError()
                        .json(AppError::DatabaseTransaction.to_response());
                }

                return HttpResponse::Unauthorized().json(GenericResponse {
                    code: "REFRESH_TOKEN_EXPIRED".to_string(),
                    message: "Refresh token expired".to_string(),
                });
            }
        }
        _ => {
            return HttpResponse::Unauthorized().json(AppError::InvalidRefreshToken.to_response());
        }
    };

    // Remove token and create a new one so the user never has to
    // connect again, unless after 7 days of inactivity.
    if let Err(e) = delete_token(claims.jti, &mut *transaction).await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match redis_client.get_multiplexed_async_connection().await {
        Ok(mut con) => {
            let result: Result<(), redis::RedisError> = con
                .publish(
                    "user_token_removed",
                    json!(UserTokenRemovedEvent {
                        token_id: claims.jti,
                        user_id: claims.user_id,
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
    };

    cached_tokens.remove_key(claims.jti).await;

    let user = match get_user_by_id(&mut *transaction, claims.user_id).await {
        Ok(r) => match r {
            Some(u) => u,
            None => {
                return HttpResponse::Unauthorized().json(AppError::UserNotFound.to_response());
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseTransaction.to_response());
        }
    };

    let new_jti = Uuid::new_v4();

    let (new_access_token, _) = generate_access_token(
        secret.as_bytes(),
        new_jti,
        claims.user_id,
        claims.is_admin,
        user.username.clone(),
    );
    let (new_refresh_token, refresh_token_expires_at) = generate_refresh_token(
        secret.as_bytes(),
        new_jti,
        claims.user_id,
        claims.is_admin,
        user.username.clone(),
    );
    let parsed_device_info = get_user_agent(req).await;

    let new_token = match save_tokens(
        claims.user_id,
        new_jti,
        refresh_token_expires_at,
        parsed_device_info,
        &mut *transaction,
    )
    .await
    {
        Ok(new_token) => new_token,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseTransaction.to_response());
        }
    };

    cached_tokens.update_or_insert_key(new_jti, now()).await;

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
                    json!(UserTokenUpdatedEvent {
                        token: new_token,
                        user,
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

    HttpResponse::Ok().json(RefreshTokenResponse {
        code: "TOKEN_REFRESHED".to_string(),
        access_token: new_access_token,
        refresh_token: new_refresh_token,
    })
}
