use std::time::Duration;

use actix_web::get;
use actix_web::web::{Data, Query};
use actix_web::{rt, web, HttpRequest, HttpResponse, Responder};
use actix_ws::{self, Message};
use chrono::{DateTime, Utc};
use futures::{select, FutureExt, StreamExt};
use jsonwebtoken::{decode, DecodingKey, Validation};
use sqlx::PgPool;
use tracing::{debug, error, info};
use uuid::Uuid;

use api::core::constants::errors::AppError;
use api::core::helpers::mock_now::now;
use api::features::auth::helpers::token::get_user_token;
use api::features::auth::structs::models::Claims;
use api::features::private_discussions::structs::models::channels_data::ChannelsData;
use api::features::private_discussions::structs::requests::private_message::ListenForNewMessages;

#[get("/ws")]
async fn broadcast_ws(
    req: HttpRequest,
    stream: web::Payload,
    query: Query<ListenForNewMessages>,
    pool: Data<PgPool>,
    channels_data: Data<ChannelsData>,
    secret: Data<String>,
) -> impl Responder {
    let params = query.into_inner();

    let decoding_key = DecodingKey::from_secret(secret.as_bytes());
    let token_data = decode::<Claims>(&params.access_token, &decoding_key, &Validation::default());

    let request_claims = match token_data {
        Ok(token_data) => {
            if now() > DateTime::<Utc>::from_timestamp(token_data.claims.exp, 0).unwrap() {
                return HttpResponse::Unauthorized()
                    .json(AppError::AccessTokenExpired.to_response());
            }

            token_data.claims
        }
        Err(error) => {
            error!("Error: {}", error);
            return HttpResponse::Unauthorized().json(AppError::InvalidAccessToken.to_response());
        }
    };

    let (res, mut session, msg_stream) = match actix_ws::handle(&req, stream) {
        Ok(r) => r,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::Unauthorized()
                .json(AppError::FailedToCreateSocketSession.to_response());
        }
    };

    let token = match get_user_token(request_claims.user_id, request_claims.jti, &**pool).await {
        Ok(Some(token)) => token,
        Ok(None) => {
            return HttpResponse::Unauthorized().json(AppError::UserTokenNotFound.to_response());
        }
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let session_uuid = Uuid::new_v4();

    channels_data
        .insert(
            request_claims.user_id,
            token.id,
            session_uuid,
            session.clone(),
        )
        .await;

    info!(
        "{} just opened a websocket : {} using the token : {}",
        request_claims.username, session_uuid, token.id,
    );

    // spawn websocket handler (and don't await it) so that the response is returned immediately
    rt::spawn(async move {
        let mut interval = tokio::time::interval(Duration::from_secs(3));
        let mut msg_stream = msg_stream.fuse();

        loop {
            select! {
                _ = interval.tick().fuse() => {
                    debug!("Sending ping to {}", request_claims.username);

                    if session.ping(b"").await.is_err() {
                        break;
                    }
                }

                msg = msg_stream.next() => {
                    match msg {
                        Some(Ok(Message::Close(reason))) => {
                            info!("{} closed socket: {:?}", request_claims.username, reason);
                            break;
                        }
                        Some(Ok(Message::Pong(_))) => {
                            debug!("Received pong from {}", request_claims.username);
                        }
                        Some(Ok(_)) => {
                            // You can handle other messages here
                        }
                        Some(Err(e)) => {
                            error!("WebSocket error: {:?}", e);
                            break;
                        }
                        None => {
                            debug!("WebSocket stream ended for {}", request_claims.username);
                            break;
                        }
                    }
                }
            }
        }

        channels_data
            .remove_key(request_claims.user_id, token.id, session_uuid)
            .await;

        let _ = session.close(None).await;

        info!(
            "{} just closed a websocket : {}",
            request_claims.username, session_uuid
        );
    });

    res
}
