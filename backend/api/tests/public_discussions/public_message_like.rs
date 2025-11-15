use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};

use api::features::public_discussions::application::dto::{
    requests::public_message_like::PublicMessageLikeCreateRequest,
    responses::public_message_like::PublicMessageLikeResponse,
};
use sqlx::PgPool;
use uuid::Uuid;

use crate::{
    auth::{login::user_logs_in, signup::user_signs_up},
    challenges::challenge::user_creates_a_challenge,
    helpers::spawn_app,
};

use super::public_message::{user_creates_a_public_message, user_gets_liked_messages};

pub async fn user_creates_a_public_message_like(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    message_id: Uuid,
) {
    let req = test::TestRequest::post()
        .uri("/api/public-message-likes/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(PublicMessageLikeCreateRequest { message_id })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessageLikeResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_LIKE_CREATED");
}

pub async fn user_deletes_a_public_message_like(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    message_id: Uuid,
) {
    let req = test::TestRequest::delete()
        .uri(&format!("/api/public-message-likes/{}", message_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessageLikeResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_LIKE_DELETED");
}

#[sqlx::test]
pub async fn user_can_like_a_public_message(pool: PgPool) {
    let app = spawn_app(pool).await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let public_message_likes = user_gets_liked_messages(&app, &access_token).await;
    assert_eq!(public_message_likes.len(), 0);

    let public_message = user_creates_a_public_message(
        &app,
        &access_token,
        Some(challenge_id),
        None,
        None,
        None,
        "Hello".to_string(),
    )
    .await;

    user_creates_a_public_message_like(&app, &access_token, public_message).await;

    let public_message_likes = user_gets_liked_messages(&app, &access_token).await;
    assert_eq!(public_message_likes.len(), 1);
}

#[sqlx::test]
pub async fn user_can_delete_a_like_on_a_public_message(pool: PgPool) {
    let app = spawn_app(pool).await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let public_message_likes = user_gets_liked_messages(&app, &access_token).await;
    assert_eq!(public_message_likes.len(), 0);

    let public_message = user_creates_a_public_message(
        &app,
        &access_token,
        Some(challenge_id),
        None,
        None,
        None,
        "Hello".to_string(),
    )
    .await;

    user_creates_a_public_message_like(&app, &access_token, public_message).await;

    let public_message_likes = user_gets_liked_messages(&app, &access_token).await;
    assert_eq!(public_message_likes.len(), 1);

    user_deletes_a_public_message_like(&app, &access_token, public_message).await;

    let public_message_likes = user_gets_liked_messages(&app, &access_token).await;
    assert_eq!(public_message_likes.len(), 0);
}
