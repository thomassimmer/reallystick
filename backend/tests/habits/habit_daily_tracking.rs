use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};

use chrono::{Duration, NaiveDate};
use reallystick::features::habits::structs::{
    models::habit_daily_tracking::HabitDailyTrackingData,
    responses::habit_daily_tracking::{HabitDailyTrackingResponse, HabitDailyTrackingsResponse},
};
use uuid::Uuid;

use crate::{
    auth::signup::user_signs_up, habits::habit::user_creates_a_habit,
    habits::habit_category::user_creates_a_habit_category, helpers::spawn_app,
};

pub async fn user_creates_a_habit_daily_tracking(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_id: Uuid,
) -> Uuid {
    let req = test::TestRequest::post()
        .uri("/api/habit-daily-tracking/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "habit_id": habit_id,
            "day": NaiveDate::from_ymd_opt(2024, 11, 15),
            "duration": Some(Duration::minutes(30).num_seconds()),
            "quantity_per_set": Some(10),
            "quantity_of_set": Some(3),
            "unit": Some("reps".to_string()),
            "reset": false,
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitDailyTrackingResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_DAILY_TRACKING_CREATED");
    assert!(response.habit_daily_tracking.is_some());

    response.habit_daily_tracking.unwrap().id
}

pub async fn user_updates_a_habit_daily_tracking(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_daily_tracking_id: Uuid,
) {
    let req = test::TestRequest::put()
        .uri(&format!(
            "/api/habit-daily-tracking/{}",
            habit_daily_tracking_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "day": NaiveDate::from_ymd_opt(2024, 11, 15),
            "duration": Some(Duration::minutes(10).num_seconds()),
            "quantity_per_set": Some(10),
            "quantity_of_set": Some(2),
            "unit": Some("reps".to_string()),
            "reset": false,
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitDailyTrackingResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_DAILY_TRACKING_UPDATED");
    assert!(response.habit_daily_tracking.is_some());
    assert_eq!(
        response.habit_daily_tracking.clone().unwrap().duration,
        Some(Duration::minutes(10)),
    );
    assert_eq!(
        response.habit_daily_tracking.unwrap().quantity_of_set,
        Some(2)
    );
}

pub async fn user_deletes_a_habit_daily_tracking(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_daily_tracking_id: Uuid,
) {
    let req = test::TestRequest::delete()
        .uri(&format!(
            "/api/habit-daily-tracking/{}",
            habit_daily_tracking_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitDailyTrackingResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_DAILY_TRACKING_DELETED");
    assert!(response.habit_daily_tracking.is_none());
}

pub async fn user_gets_habit_daily_trackings(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<HabitDailyTrackingData> {
    let req = test::TestRequest::get()
        .uri("/api/habit-daily-tracking/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitDailyTrackingsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_DAILY_TRACKING_FETCHED");
    response.habit_daily_trackings
}

#[tokio::test]
pub async fn user_can_create_a_habit_daily_tracking() {
    let app = spawn_app().await;
    let (access_token, _, _) = user_signs_up(&app).await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let habit_id = user_creates_a_habit(&app, &access_token, habit_category_id).await;

    let habit_daily_trackings = user_gets_habit_daily_trackings(&app, &access_token).await;
    assert!(habit_daily_trackings.is_empty());

    user_creates_a_habit_daily_tracking(&app, &access_token, habit_id).await;

    let habit_daily_trackings = user_gets_habit_daily_trackings(&app, &access_token).await;
    assert!(!habit_daily_trackings.is_empty());
}

#[tokio::test]
pub async fn user_can_update_a_habit_daily_tracking() {
    let app = spawn_app().await;
    let (access_token, _, _) = user_signs_up(&app).await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let habit_id = user_creates_a_habit(&app, &access_token, habit_category_id).await;

    let habit_daily_tracking_id =
        user_creates_a_habit_daily_tracking(&app, &access_token, habit_id).await;
    user_updates_a_habit_daily_tracking(app, &access_token, habit_daily_tracking_id).await;
}

#[tokio::test]
pub async fn user_can_delete_a_habit_daily_tracking() {
    let app = spawn_app().await;
    let (access_token, _, _) = user_signs_up(&app).await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let habit_id = user_creates_a_habit(&app, &access_token, habit_category_id).await;

    let habit_daily_trackings = user_gets_habit_daily_trackings(&app, &access_token).await;
    assert!(habit_daily_trackings.is_empty());

    let habit_daily_tracking_id =
        user_creates_a_habit_daily_tracking(&app, &access_token, habit_id).await;

    let habit_daily_trackings = user_gets_habit_daily_trackings(&app, &access_token).await;
    assert!(!habit_daily_trackings.is_empty());

    user_deletes_a_habit_daily_tracking(&app, &access_token, habit_daily_tracking_id).await;

    let habit_daily_trackings = user_gets_habit_daily_trackings(&app, &access_token).await;
    assert!(habit_daily_trackings.is_empty());
}
