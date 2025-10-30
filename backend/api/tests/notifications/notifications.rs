use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    test, Error,
};
use api::features::{
    notifications::structs::{
        models::NotificationData,
        responses::{NotificationResponse, NotificationsResponse},
    },
    private_discussions::structs::responses::private_message::PrivateMessageResponse,
};
use uuid::Uuid;

use crate::{
    auth::{login::user_logs_in, signup::user_signs_up},
    challenges::{
        challenge::user_creates_a_challenge,
        challenge_participation::user_creates_a_challenge_participation,
    },
    helpers::spawn_app,
};

pub async fn user_gets_notifications(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<NotificationData> {
    let req: Request = test::TestRequest::get()
        .uri("/api/notifications/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: NotificationsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "NOTIFICATIONS_FETCHED");

    response.notifications
}

pub async fn user_marks_a_notification_as_seen(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    notification_id: Uuid,
) {
    let req = test::TestRequest::put()
        .uri(&format!(
            "/api/notifications/mark-as-seen/{}",
            notification_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: NotificationResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "NOTIFICATION_MARKED_AS_SEEN");
}

pub async fn user_deletes_a_notification(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    notification_id: Uuid,
) {
    let req = test::TestRequest::delete()
        .uri(&format!("/api/notifications/{}", notification_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: NotificationResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "NOTIFICATION_DELETED");
}

pub async fn user_deletes_all_notifications(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) {
    let req = test::TestRequest::delete()
        .uri("/api/notifications/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PrivateMessageResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "NOTIFICATIONS_DELETED");
}

#[tokio::test]
pub async fn user_can_mark_a_notification_as_seen() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let notifications = user_gets_notifications(&app, &access_token).await;
    assert_eq!(notifications.len(), 0);

    let (access_token, _) = user_signs_up(&app, None).await;
    user_creates_a_challenge_participation(&app, &access_token, challenge_id).await;

    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let notifications = user_gets_notifications(&app, &access_token).await;
    assert_eq!(notifications.len(), 1);

    let notification = notifications.first().unwrap();
    assert!(!notification.seen);

    user_marks_a_notification_as_seen(&app, &access_token, notification.id).await;

    let notifications = user_gets_notifications(&app, &access_token).await;
    assert_eq!(notifications.len(), 1);

    let notification = notifications.first().unwrap();
    assert!(notification.seen);
}

#[tokio::test]
pub async fn user_can_delete_a_notification() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let notifications = user_gets_notifications(&app, &access_token).await;
    assert_eq!(notifications.len(), 0);

    let (access_token, _) = user_signs_up(&app, None).await;
    user_creates_a_challenge_participation(&app, &access_token, challenge_id).await;

    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let notifications = user_gets_notifications(&app, &access_token).await;
    assert_eq!(notifications.len(), 1);

    let notification = notifications.first().unwrap();

    user_deletes_a_notification(&app, &access_token, notification.id).await;

    let notifications = user_gets_notifications(&app, &access_token).await;
    assert_eq!(notifications.len(), 0);
}

#[tokio::test]
pub async fn user_can_delete_all_notifications() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let notifications = user_gets_notifications(&app, &access_token).await;
    assert_eq!(notifications.len(), 0);

    let (access_token, _) = user_signs_up(&app, None).await;
    user_creates_a_challenge_participation(&app, &access_token, challenge_id).await;

    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let notifications = user_gets_notifications(&app, &access_token).await;
    assert_eq!(notifications.len(), 1);

    user_deletes_all_notifications(&app, &access_token).await;

    let notifications = user_gets_notifications(&app, &access_token).await;
    assert_eq!(notifications.len(), 0);
}
