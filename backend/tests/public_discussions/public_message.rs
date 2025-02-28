use std::collections::HashSet;

use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};

use reallystick::features::public_discussions::structs::{
    models::public_message::PublicMessageData,
    requests::public_message::{PublicMessageCreateRequest, PublicMessageUpdateRequest},
    responses::public_message::{PublicMessageResponse, PublicMessagesResponse},
};
use uuid::Uuid;

use crate::{
    auth::{login::user_logs_in, signup::user_signs_up},
    challenges::challenge::user_creates_a_challenge,
    habits::{
        habit::user_creates_a_habit, habit_category::user_creates_a_habit_category,
        unit::user_creates_a_unit,
    },
    helpers::spawn_app,
};

pub async fn user_creates_a_public_message(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_id: Option<Uuid>,
    habit_id: Option<Uuid>,
    thread_id: Option<Uuid>,
    replies_to: Option<Uuid>,
    content: String,
) -> Uuid {
    let req = test::TestRequest::post()
        .uri("/api/public-messages/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(PublicMessageCreateRequest {
            challenge_id,
            habit_id,
            thread_id,
            replies_to,
            content,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessageResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_CREATED");
    assert!(response.message.is_some());

    response.message.unwrap().id
}

pub async fn user_updates_a_public_message(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    public_message_id: Uuid,
    content: String,
) {
    let req = test::TestRequest::put()
        .uri(&format!("/api/public-messages/{}", public_message_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(PublicMessageUpdateRequest {
            content: content.clone(),
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessageResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_UPDATED");
    assert!(response.message.is_some());
    assert_eq!(response.message.unwrap().content, content);
}

pub async fn user_deletes_a_public_message(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    public_message_id: Uuid,
    deleted_by_admin: bool,
) {
    let req = test::TestRequest::delete()
        .uri(&format!(
            "/api/public-messages/?message_id={}&deleted_by_admin={}",
            public_message_id, deleted_by_admin
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessageResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_DELETED");
    assert!(response.message.is_none());
}

pub async fn user_gets_public_messages(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_id: Option<Uuid>,
    habit_id: Option<Uuid>,
) -> Vec<PublicMessageData> {
    let query = if let Some(challenge_id) = challenge_id {
        format!("?challenge_id={}", challenge_id)
    } else if let Some(habit_id) = habit_id {
        format!("?habit_id={}", habit_id)
    } else {
        "".to_string()
    };

    let req = test::TestRequest::get()
        .uri(&format!("/api/public-messages/{}", query))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessagesResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_FETCHED");
    response.messages
}

pub async fn user_gets_liked_messages(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<PublicMessageData> {
    let req = test::TestRequest::get()
        .uri(&format!("/api/public-messages/liked/",))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessagesResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_FETCHED");
    response.messages
}

pub async fn user_gets_written_messages(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<PublicMessageData> {
    let req = test::TestRequest::get()
        .uri(&format!("/api/public-messages/written/",))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessagesResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_FETCHED");
    response.messages
}

pub async fn user_gets_replies(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    message_id: Uuid,
) -> Vec<PublicMessageData> {
    let req = test::TestRequest::get()
        .uri(&format!("/api/public-messages/replies/{}", message_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessagesResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_FETCHED");
    response.messages
}

pub async fn user_gets_parents(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    message_id: Uuid,
) -> Vec<PublicMessageData> {
    let req = test::TestRequest::get()
        .uri(&format!("/api/public-messages/parents/{}", message_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessagesResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_FETCHED");
    response.messages
}

#[tokio::test]
pub async fn user_can_create_a_public_message_on_a_habit() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let unit_id = user_creates_a_unit(&app, &access_token).await;
    let habit_id = user_creates_a_habit(
        &app,
        &access_token,
        habit_category_id,
        HashSet::from([unit_id]),
    )
    .await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, None, Some(habit_id)).await;
    assert_eq!(public_messages.len(), 0);

    user_creates_a_public_message(
        &app,
        &access_token,
        None,
        Some(habit_id),
        None,
        None,
        "Hello".to_string(),
    )
    .await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, None, Some(habit_id)).await;
    assert_eq!(public_messages.len(), 1);
}

#[tokio::test]
pub async fn user_can_create_a_public_message_on_a_challenge() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 0);

    user_creates_a_public_message(
        &app,
        &access_token,
        Some(challenge_id),
        None,
        None,
        None,
        "Hello".to_string(),
    )
    .await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 1);
}

#[tokio::test]
pub async fn user_can_answer_a_public_message() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 0);

    let public_message_1 = user_creates_a_public_message(
        &app,
        &access_token,
        Some(challenge_id),
        None,
        None,
        None,
        "Ping".to_string(),
    )
    .await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 1);

    let (access_token, _) = user_signs_up(&app, Some("user2")).await;

    let public_message_2 = user_creates_a_public_message(
        &app,
        &access_token,
        Some(challenge_id),
        None,
        Some(public_message_1),
        Some(public_message_1),
        "Pong".to_string(),
    )
    .await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 1);

    let replies = user_gets_replies(&app, &access_token, public_message_1).await;
    assert_eq!(replies.len(), 1);
    assert_eq!(replies[0].id, public_message_2);

    let parents = user_gets_parents(&app, &access_token, public_message_2).await;
    assert_eq!(parents.len(), 1);
    assert_eq!(parents[0].id, public_message_1);
}

#[tokio::test]
pub async fn creator_can_update_a_public_message() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 0);

    let public_message_id = user_creates_a_public_message(
        &app,
        &access_token,
        Some(challenge_id),
        None,
        None,
        None,
        "Hello".to_string(),
    )
    .await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 1);

    user_updates_a_public_message(app, &access_token, public_message_id, "Hello!".to_string())
        .await;
}

#[tokio::test]
pub async fn creator_can_delete_a_public_message() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 0);

    let public_message_id = user_creates_a_public_message(
        &app,
        &access_token,
        Some(challenge_id),
        None,
        None,
        None,
        "Hello".to_string(),
    )
    .await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 1);

    user_deletes_a_public_message(&app, &access_token, public_message_id, false).await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 0);
}

#[tokio::test]
pub async fn admin_can_delete_a_public_message() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 0);

    let public_message_id = user_creates_a_public_message(
        &app,
        &access_token,
        Some(challenge_id),
        None,
        None,
        None,
        "Hello".to_string(),
    )
    .await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 1);

    let (access_token, _) = user_logs_in(&app, "thomas", "").await;

    user_deletes_a_public_message(&app, &access_token, public_message_id, true).await;

    let public_messages =
        user_gets_public_messages(&app, &access_token, Some(challenge_id), None).await;
    assert_eq!(public_messages.len(), 0);
}
