use std::collections::HashSet;

use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use reallystick::features::habits::structs::{
    models::habit_participation::HabitParticipationData,
    responses::habit_participation::{HabitParticipationResponse, HabitParticipationsResponse},
};
use uuid::Uuid;

use crate::{
    auth::{login::user_logs_in, signup::user_signs_up},
    habits::{
        habit::user_creates_a_habit, habit_category::user_creates_a_habit_category,
        unit::user_creates_a_unit,
    },
    helpers::spawn_app,
};

pub async fn user_creates_a_habit_participation(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_id: Uuid,
) -> Uuid {
    let req = test::TestRequest::post()
        .uri("/api/habit-participations/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "habit_id": habit_id,
            "color": "blue",
            "to_gain": true,
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitParticipationResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_PARTICIPATION_CREATED");
    assert!(response.habit_participation.is_some());

    response.habit_participation.unwrap().id
}

pub async fn user_updates_a_habit_participation(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_participation_id: Uuid,
) {
    let req = test::TestRequest::put()
        .uri(&format!(
            "/api/habit-participations/{}",
            habit_participation_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "color": "yellow",
            "to_gain": false,
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitParticipationResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_PARTICIPATION_UPDATED");
    assert!(response.habit_participation.is_some());
    assert_eq!(
        response.habit_participation.clone().unwrap().color,
        "yellow"
    );
    assert_eq!(response.habit_participation.unwrap().to_gain, false);
}

pub async fn user_deletes_a_habit_participation(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_participation_id: Uuid,
) {
    let req = test::TestRequest::delete()
        .uri(&format!(
            "/api/habit-participations/{}",
            habit_participation_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitParticipationResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_PARTICIPATION_DELETED");
    assert!(response.habit_participation.is_none());
}

pub async fn user_gets_habit_participations(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<HabitParticipationData> {
    let req = test::TestRequest::get()
        .uri("/api/habit-participations/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitParticipationsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_PARTICIPATIONS_FETCHED");
    response.habit_participations
}

#[tokio::test]
pub async fn user_can_create_a_habit_participation() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let unit_id = user_creates_a_unit(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;
    let habit_id = user_creates_a_habit(
        &app,
        &access_token,
        habit_category_id,
        HashSet::from([unit_id]),
    )
    .await;

    let habit_participations = user_gets_habit_participations(&app, &access_token).await;
    assert!(habit_participations.is_empty());

    user_creates_a_habit_participation(&app, &access_token, habit_id).await;

    let habit_participations = user_gets_habit_participations(&app, &access_token).await;
    assert!(!habit_participations.is_empty());
}

#[tokio::test]
pub async fn user_can_update_a_habit_participation() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let unit_id = user_creates_a_unit(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;
    let habit_id = user_creates_a_habit(
        &app,
        &access_token,
        habit_category_id,
        HashSet::from([unit_id]),
    )
    .await;

    let habit_participation_id =
        user_creates_a_habit_participation(&app, &access_token, habit_id).await;
    user_updates_a_habit_participation(app, &access_token, habit_participation_id).await;
}

#[tokio::test]
pub async fn user_can_delete_a_habit_participation() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let unit_id = user_creates_a_unit(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;
    let habit_id = user_creates_a_habit(
        &app,
        &access_token,
        habit_category_id,
        HashSet::from([unit_id]),
    )
    .await;

    let habit_participations = user_gets_habit_participations(&app, &access_token).await;
    assert!(habit_participations.is_empty());

    let habit_participation_id =
        user_creates_a_habit_participation(&app, &access_token, habit_id).await;

    let habit_participations = user_gets_habit_participations(&app, &access_token).await;
    assert!(!habit_participations.is_empty());

    user_deletes_a_habit_participation(&app, &access_token, habit_participation_id).await;

    let habit_participations = user_gets_habit_participations(&app, &access_token).await;
    assert!(habit_participations.is_empty());
}
