use actix_web::get;
use actix_web::web::{Data, Query};
use actix_web::{rt, web, HttpRequest, HttpResponse, Responder};
use actix_ws::{self};
use futures::TryStreamExt;
use jsonwebtoken::{decode, DecodingKey, Validation};

use crate::core::constants::errors::AppError;
use crate::features::auth::structs::models::Claims;

use crate::features::private_discussions::structs::models::private_message::ChannelsData;
use crate::features::private_discussions::structs::requests::private_message::ListenForNewMessages;

#[get("/ws")]
async fn broadcast_ws(
    req: HttpRequest,
    stream: web::Payload,
    query: Query<ListenForNewMessages>,
    channels_data: Data<ChannelsData>,
    secret: Data<String>,
) -> impl Responder {
    let params = query.into_inner();

    let decoding_key = DecodingKey::from_secret(secret.as_bytes());
    let token_data = decode::<Claims>(&params.access_token, &decoding_key, &Validation::default());

    let request_claims = match token_data {
        Ok(token_data) => token_data.claims,
        Err(error) => {
            eprintln!("Error: {}", error);
            return HttpResponse::Unauthorized().json(AppError::InvalidAccessToken.to_response());
        }
    };

    let (res, session, mut msg_stream) = match actix_ws::handle(&req, stream) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::Unauthorized()
                .json(AppError::FailedToCreateSocketSession.to_response());
        }
    };

    channels_data
        .insert(request_claims.user_id, session.clone())
        .await;

    // spawn websocket handler (and don't await it) so that the response is returned immediately
    rt::spawn(async move {
        while let Ok(Some(msg)) = msg_stream.try_next().await {
            match msg {
                _ => break,
            }
        }

        channels_data.remove_key(request_claims.user_id).await;
        let _ = session.close(None).await;
    });

    res
}
