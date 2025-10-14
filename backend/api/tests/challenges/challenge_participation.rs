use std::time::Duration;

use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use chrono::{Datelike, Utc};
use api::features::challenges::structs::{
    models::challenge_participation::ChallengeParticipationData,
    requests::challenge_participation::ChallengeParticipationUpdateRequest,
    responses::challenge_participation::{
        ChallengeParticipationResponse, ChallengeParticipationsResponse,
    },
};
use uuid::Uuid;

use crate::{
    auth::{login::user_logs_in, signup::user_signs_up},
    challenges::challenge::user_creates_a_challenge,
    helpers::spawn_app,
};

pub async fn user_creates_a_challenge_participation(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_id: Uuid,
) -> Uuid {
    let req = test::TestRequest::post()
        .uri("/api/challenge-participations/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "challenge_id": challenge_id,
            "color": "blue",
            "start_date": Utc::now(),
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeParticipationResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_PARTICIPATION_CREATED");
    assert!(response.challenge_participation.is_some());

    response.challenge_participation.unwrap().id
}

pub async fn user_updates_a_challenge_participation(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_participation_id: Uuid,
) {
    let req = test::TestRequest::put()
        .uri(&format!(
            "/api/challenge-participations/{}",
            challenge_participation_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(ChallengeParticipationUpdateRequest {
            color: "yellow".to_string(),
            start_date: Utc::now() + Duration::new(24 * 3600 * 2, 0),
            notifications_reminder_enabled: false,
            reminder_time: None,
            reminder_body: None,
            finished: false,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeParticipationResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_PARTICIPATION_UPDATED");
    assert!(response.challenge_participation.is_some());
    assert_eq!(
        response.challenge_participation.clone().unwrap().color,
        "yellow"
    );
    assert_eq!(
        response.challenge_participation.unwrap().start_date.day(),
        (Utc::now() + Duration::new(24 * 3600 * 2, 0)).day()
    );
}

pub async fn user_deletes_a_challenge_participation(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_participation_id: Uuid,
) {
    let req = test::TestRequest::delete()
        .uri(&format!(
            "/api/challenge-participations/{}",
            challenge_participation_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeParticipationResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_PARTICIPATION_DELETED");
    assert!(response.challenge_participation.is_none());
}

pub async fn user_gets_challenge_participations(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<ChallengeParticipationData> {
    let req = test::TestRequest::get()
        .uri("/api/challenge-participations/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeParticipationsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_PARTICIPATIONS_FETCHED");
    response.challenge_participations
}

#[tokio::test]
pub async fn user_can_create_a_challenge_participation() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let challenge_participations = user_gets_challenge_participations(&app, &access_token).await;
    assert!(challenge_participations.is_empty());

    user_creates_a_challenge_participation(&app, &access_token, challenge_id).await;

    let challenge_participations = user_gets_challenge_participations(&app, &access_token).await;
    assert!(!challenge_participations.is_empty());
}

#[tokio::test]
pub async fn user_can_update_a_challenge_participation() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let challenge_participation_id =
        user_creates_a_challenge_participation(&app, &access_token, challenge_id).await;

    user_updates_a_challenge_participation(app, &access_token, challenge_participation_id).await;
}

#[tokio::test]
pub async fn user_can_delete_a_challenge_participation() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let challenge_participation_id =
        user_creates_a_challenge_participation(&app, &access_token, challenge_id).await;

    let challenge_participations = user_gets_challenge_participations(&app, &access_token).await;
    assert!(!challenge_participations.is_empty());

    user_deletes_a_challenge_participation(&app, &access_token, challenge_participation_id).await;

    let challenge_participations = user_gets_challenge_participations(&app, &access_token).await;
    assert!(challenge_participations.is_empty());
}
