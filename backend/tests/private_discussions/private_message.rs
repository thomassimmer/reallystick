use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use reallystick::features::private_discussions::structs::{
    models::private_message::PrivateMessageData,
    requests::private_message::{PrivateMessageCreateRequest, PrivateMessageUpdateRequest},
    responses::private_message::{PrivateMessageResponse, PrivateMessagesResponse},
};
use uuid::Uuid;

use crate::{
    auth::{login::user_logs_in, recovery_code::generate_key_pair, signup::user_signs_up},
    helpers::spawn_app,
    private_discussions::private_discussion::{
        user_creates_a_private_discussion, user_gets_private_discussions,
    },
    profile::profile::user_has_access_to_protected_route,
};

pub fn encrypt_message_for_a_and_b(
    _message: &str,
    _a_public_key: &str,
    _b_public_key: &str,
) -> (String, String, String, String) {
    (
        String::from("content"),
        String::from("nonce"),
        String::new(),
        String::new(),
    )
}

pub async fn user_creates_a_private_message(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    discussion_id: Uuid,
    content: String,
    _nonce: String,
    creator_encrypted_session_key: String,
    recipient_encrypted_session_key: String,
) -> Uuid {
    let req = test::TestRequest::post()
        .uri("/api/private-messages/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(PrivateMessageCreateRequest {
            discussion_id,
            content,
            creator_encrypted_session_key,
            recipient_encrypted_session_key,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PrivateMessageResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PRIVATE_MESSAGE_CREATED");
    assert!(response.message.is_some());

    response.message.unwrap().id
}

pub async fn user_updates_a_private_message(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    private_message_id: Uuid,
    content: String,
) {
    let req = test::TestRequest::put()
        .uri(&format!("/api/private-messages/{}", private_message_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(PrivateMessageUpdateRequest {
            content: content.clone(),
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PrivateMessageResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PRIVATE_MESSAGE_UPDATED");
    assert!(response.message.is_some());
    assert_eq!(response.message.unwrap().content, content);
}

pub async fn user_marks_a_private_message_as_seen(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    private_message_id: Uuid,
) {
    let req = test::TestRequest::get()
        .uri(&format!(
            "/api/private-messages/mark-as-seen/{}",
            private_message_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PrivateMessageResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PRIVATE_MESSAGE_UPDATED");
    assert!(response.message.is_some());
    assert_eq!(response.message.unwrap().seen, true);
}

pub async fn user_deletes_a_private_message(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    private_message_id: Uuid,
) {
    let req = test::TestRequest::delete()
        .uri(&format!(
            "/api/private-messages/?message_id={}",
            private_message_id,
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PrivateMessageResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PRIVATE_MESSAGE_DELETED");
    assert!(response.message.is_none());
}

pub async fn user_gets_private_messages_of_discussion(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    discussion_id: Uuid,
) -> Vec<PrivateMessageData> {
    let req = test::TestRequest::get()
        .uri(&format!("/api/private-messages/{}", discussion_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PrivateMessagesResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PRIVATE_MESSAGE_FETCHED");
    response.messages
}

#[tokio::test]
pub async fn user_can_create_a_private_message() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let thomas_id = user_has_access_to_protected_route(&app, &access_token)
        .await
        .id;
    let (_, recipient_public_key) = generate_key_pair();

    let (access_token, _) = user_signs_up(&app, None).await;
    let (_, other_user_public_key) = generate_key_pair();

    user_creates_a_private_discussion(&app, &access_token, thomas_id, "blue").await;

    let discussion_id = user_gets_private_discussions(&app, &access_token).await[0].id;

    let private_messages =
        user_gets_private_messages_of_discussion(&app, &access_token, discussion_id).await;
    assert_eq!(private_messages.len(), 0);

    let content = "Hello";
    let (
        encrypted_content,
        nonce,
        encrypted_session_key_for_recipient,
        encrypted_session_key_for_creator,
    ) = encrypt_message_for_a_and_b(content, &recipient_public_key, &other_user_public_key);

    let private_message_id = user_creates_a_private_message(
        &app,
        &access_token,
        discussion_id,
        encrypted_content.clone(),
        nonce,
        encrypted_session_key_for_creator,
        encrypted_session_key_for_recipient,
    )
    .await;

    let private_messages =
        user_gets_private_messages_of_discussion(&app, &access_token, discussion_id).await;

    assert_eq!(private_messages.len(), 1);
    assert_eq!(private_messages[0].content, encrypted_content);
    assert_eq!(private_messages[0].seen, false);

    let (access_token, _) = user_logs_in(&app, "thomas", "").await;

    user_marks_a_private_message_as_seen(&app, &access_token, private_message_id).await;

    let private_messages =
        user_gets_private_messages_of_discussion(&app, &access_token, discussion_id).await;

    assert_eq!(private_messages.len(), 1);
    assert_eq!(private_messages[0].seen, true);
}

#[tokio::test]
pub async fn user_can_delete_a_private_message() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let thomas_id = user_has_access_to_protected_route(&app, &access_token)
        .await
        .id;
    let (_, recipient_public_key) = generate_key_pair();

    let (access_token, _) = user_signs_up(&app, None).await;
    let (_, other_user_public_key) = generate_key_pair();

    let discussion_id =
        user_creates_a_private_discussion(&app, &access_token, thomas_id, "blue").await;

    let content = "Hello";
    let (
        encrypted_content,
        nonce,
        encrypted_session_key_for_recipient,
        encrypted_session_key_for_creator,
    ) = encrypt_message_for_a_and_b(content, &recipient_public_key, &other_user_public_key);

    let private_message_id = user_creates_a_private_message(
        &app,
        &access_token,
        discussion_id,
        encrypted_content.clone(),
        nonce,
        encrypted_session_key_for_creator,
        encrypted_session_key_for_recipient,
    )
    .await;

    let private_messages =
        user_gets_private_messages_of_discussion(&app, &access_token, discussion_id).await;

    assert_eq!(private_messages.len(), 1);
    assert_eq!(private_messages[0].deleted, false);

    user_deletes_a_private_message(&app, &access_token, private_message_id).await;

    let private_messages =
        user_gets_private_messages_of_discussion(&app, &access_token, discussion_id).await;

    assert_eq!(private_messages.len(), 1);
    assert_eq!(private_messages[0].deleted, true);
}
