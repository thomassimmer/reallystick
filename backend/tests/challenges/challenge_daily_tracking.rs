use std::collections::HashSet;

use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};

use reallystick::features::challenges::structs::{
    models::challenge_daily_tracking::ChallengeDailyTrackingData,
    requests::challenge_daily_tracking::{
        ChallengeDailyTrackingCreateRequest, ChallengeDailyTrackingUpdateRequest,
    },
    responses::challenge_daily_tracking::{
        ChallengeDailyTrackingResponse, ChallengeDailyTrackingsResponse,
    },
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

pub async fn user_creates_a_challenge_daily_tracking(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_id: Uuid,
    habit_id: Uuid,
    unit_id: Uuid,
) -> Uuid {
    let req = test::TestRequest::post()
        .uri("/api/challenge-daily-trackings/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(ChallengeDailyTrackingCreateRequest {
            challenge_id,
            habit_id,
            day_of_program: 1,
            quantity_per_set: 10.0,
            quantity_of_set: 3,
            unit_id,
            weight: 0,
            weight_unit_id: unit_id,
            repeat: 1,
            note: None,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeDailyTrackingsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_DAILY_TRACKINGS_CREATED");
    assert!(response.challenge_daily_trackings.len() == 1);

    response.challenge_daily_trackings.first().unwrap().id
}

pub async fn user_updates_a_challenge_daily_tracking(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_daily_tracking_id: Uuid,
    habit_id: Uuid,
    unit_id: Uuid,
) {
    let req = test::TestRequest::put()
        .uri(&format!(
            "/api/challenge-daily-trackings/{}",
            challenge_daily_tracking_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(ChallengeDailyTrackingUpdateRequest {
            habit_id,
            day_of_program: 1,
            quantity_per_set: 10.0,
            quantity_of_set: 2,
            unit_id,
            weight: 0,
            weight_unit_id: unit_id,
            note: None,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeDailyTrackingResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_DAILY_TRACKING_UPDATED");
    assert!(response.challenge_daily_tracking.is_some());
    assert_eq!(
        response.challenge_daily_tracking.unwrap().quantity_of_set,
        2
    );
}

pub async fn user_deletes_a_challenge_daily_tracking(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_daily_tracking_id: Uuid,
) {
    let req = test::TestRequest::delete()
        .uri(&format!(
            "/api/challenge-daily-trackings/{}",
            challenge_daily_tracking_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeDailyTrackingResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_DAILY_TRACKING_DELETED");
    assert!(response.challenge_daily_tracking.is_none());
}

pub async fn user_gets_challenge_daily_trackings(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_id: Uuid,
) -> Vec<ChallengeDailyTrackingData> {
    let req = test::TestRequest::get()
        .uri(&format!("/api/challenge-daily-trackings/{}", challenge_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeDailyTrackingsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_DAILY_TRACKINGS_FETCHED");
    response.challenge_daily_trackings
}

#[tokio::test]
pub async fn creator_can_create_a_challenge_daily_tracking() {
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

    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let challenge_daily_trackings =
        user_gets_challenge_daily_trackings(&app, &access_token, challenge_id).await;
    assert!(challenge_daily_trackings.is_empty());

    user_creates_a_challenge_daily_tracking(&app, &access_token, challenge_id, habit_id, unit_id)
        .await;

    let challenge_daily_trackings =
        user_gets_challenge_daily_trackings(&app, &access_token, challenge_id).await;
    assert!(!challenge_daily_trackings.is_empty());
}

#[tokio::test]
pub async fn creator_can_update_a_challenge_daily_tracking() {
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

    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let challenge_daily_trackings =
        user_gets_challenge_daily_trackings(&app, &access_token, challenge_id).await;
    assert!(challenge_daily_trackings.is_empty());

    let challenge_daily_tracking_id = user_creates_a_challenge_daily_tracking(
        &app,
        &access_token,
        challenge_id,
        habit_id,
        unit_id,
    )
    .await;

    user_updates_a_challenge_daily_tracking(
        app,
        &access_token,
        challenge_daily_tracking_id,
        habit_id,
        unit_id,
    )
    .await;
}

#[tokio::test]
pub async fn creator_can_delete_a_challenge_daily_tracking() {
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

    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let challenge_daily_trackings =
        user_gets_challenge_daily_trackings(&app, &access_token, challenge_id).await;
    assert!(challenge_daily_trackings.is_empty());

    let challenge_daily_tracking_id = user_creates_a_challenge_daily_tracking(
        &app,
        &access_token,
        challenge_id,
        habit_id,
        unit_id,
    )
    .await;

    let challenge_daily_trackings =
        user_gets_challenge_daily_trackings(&app, &access_token, challenge_id).await;
    assert!(!challenge_daily_trackings.is_empty());

    user_deletes_a_challenge_daily_tracking(&app, &access_token, challenge_daily_tracking_id).await;

    let challenge_daily_trackings =
        user_gets_challenge_daily_trackings(&app, &access_token, challenge_id).await;
    assert!(challenge_daily_trackings.is_empty());
}
