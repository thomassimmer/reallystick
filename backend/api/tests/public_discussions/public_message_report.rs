use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};

use api::features::public_discussions::structs::{
    models::{public_message::PublicMessageData, public_message_report::PublicMessageReportData},
    requests::public_message_report::PublicMessageReportCreateRequest,
    responses::public_message_report::{PublicMessageReportResponse, PublicMessageReportsResponse},
};
use sqlx::PgPool;
use uuid::Uuid;

use crate::{
    auth::{login::user_logs_in, signup::user_signs_up},
    challenges::challenge::user_creates_a_challenge,
    helpers::spawn_app,
};

use super::public_message::user_creates_a_public_message;

pub async fn user_creates_a_public_message_report(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    message_id: Uuid,
    reason: String,
) {
    let req = test::TestRequest::post()
        .uri("/api/public-message-reports/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(PublicMessageReportCreateRequest { message_id, reason })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessageReportResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_REPORT_CREATED");
}

pub async fn user_deletes_a_public_message_report(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    message_report_id: Uuid,
) {
    let req = test::TestRequest::delete()
        .uri(&format!(
            "/api/public-message-reports/{}",
            message_report_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessageReportResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_REPORT_DELETED");
}

pub async fn user_gets_user_message_reports(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> (Vec<PublicMessageData>, Vec<PublicMessageReportData>) {
    let req = test::TestRequest::get()
        .uri("/api/public-message-reports/me")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessageReportsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_FETCHED");
    (response.messages, response.message_reports)
}

pub async fn user_gets_message_reports(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> (Vec<PublicMessageData>, Vec<PublicMessageReportData>) {
    let req = test::TestRequest::get()
        .uri("/api/public-message-reports/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PublicMessageReportsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PUBLIC_MESSAGE_FETCHED");
    (response.messages, response.message_reports)
}

#[sqlx::test]
pub async fn user_can_report_a_public_message(pool: PgPool) {
    let app = spawn_app(pool).await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let public_message_reports = user_gets_user_message_reports(&app, &access_token).await;
    assert_eq!(public_message_reports.0.len(), 0);
    assert_eq!(public_message_reports.1.len(), 0);

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

    user_creates_a_public_message_report(&app, &access_token, public_message, "Reason".to_string())
        .await;

    let public_message_reports = user_gets_user_message_reports(&app, &access_token).await;
    assert_eq!(public_message_reports.0.len(), 1);
    assert_eq!(public_message_reports.1.len(), 1);

    let (access_token, _) = user_logs_in(&app, "thomas", "").await;

    let public_message_reports = user_gets_user_message_reports(&app, &access_token).await;
    assert_eq!(public_message_reports.0.len(), 0);
    assert_eq!(public_message_reports.1.len(), 0);

    let public_message_reports = user_gets_message_reports(&app, &access_token).await;
    assert_eq!(public_message_reports.0.len(), 1);
    assert_eq!(public_message_reports.1.len(), 1);
}
