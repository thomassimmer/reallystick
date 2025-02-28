use std::collections::HashMap;

use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use reallystick::features::habits::structs::{
    models::habit::HabitData,
    responses::habit::{HabitResponse, HabitsResponse},
};
use serde_json::json;
use uuid::Uuid;

use crate::{
    auth::signup::user_signs_up, habits::habit_category::user_creates_a_habit_category,
    helpers::spawn_app,
};

pub async fn user_creates_a_habit(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_category_id: Uuid,
) -> Uuid {
    let req = test::TestRequest::post()
        .uri("/api/habits/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "category_id": habit_category_id,
            "short_name": HashMap::from([("en", "English")]),
            "long_name": HashMap::from([("en", "Learn English")]),
            "description": HashMap::from([(
                "en",
                "Our goal is to speak English fluently!"
            )]),
            "icon": "english_icon".to_string(),
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_CREATED");
    assert!(response.habit.is_some());

    response.habit.unwrap().id
}

pub async fn user_updates_a_habit(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_category_id: Uuid,
    habit_id: Uuid,
) {
    let req = test::TestRequest::put()
        .uri(&format!("/api/habits/{}", habit_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "category_id": habit_category_id,
            "short_name": HashMap::from([("en", "English"), ("fr", "Anglais")]),
            "long_name": HashMap::from([("en", "Learn English"), ("fr", "Apprenez l'anglais")]),
            "description": HashMap::from([(
                "en",
                "Our goal is to speak English fluently!"
            )]),
            "icon": "english_icon".to_string(),
            "reviewed": true
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_UPDATED");
    assert!(response.habit.is_some());
    assert_eq!(
        response.habit.clone().unwrap().short_name,
        json!(HashMap::from([("en", "English"), ("fr", "Anglais")])).to_string()
    );
    assert_eq!(
        response.habit.unwrap().long_name,
        json!(HashMap::from([
            ("en", "Learn English"),
            ("fr", "Apprenez l'anglais")
        ]))
        .to_string()
    );
}

pub async fn user_deletes_a_habit(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_id: Uuid,
) {
    let req = test::TestRequest::delete()
        .uri(&format!("/api/habits/{}", habit_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_DELETED");
    assert!(response.habit.is_none());
}

pub async fn user_gets_habits(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<HabitData> {
    let req = test::TestRequest::get()
        .uri("/api/habits/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABITS_FETCHED");
    response.habits
}

#[tokio::test]
pub async fn user_can_create_a_habit() {
    let app = spawn_app().await;
    let (access_token, _, _) = user_signs_up(&app).await;
    let category_id = user_creates_a_habit_category(&app, &access_token).await;

    let habits = user_gets_habits(&app, &access_token).await;
    assert!(habits.is_empty());

    user_creates_a_habit(&app, &access_token, category_id).await;

    let habits = user_gets_habits(&app, &access_token).await;
    assert!(!habits.is_empty());
}

#[tokio::test]
pub async fn user_can_update_a_habit() {
    let app = spawn_app().await;
    let (access_token, _, _) = user_signs_up(&app).await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;

    let habit_id = user_creates_a_habit(&app, &access_token, habit_category_id).await;
    user_updates_a_habit(app, &access_token, habit_category_id, habit_id).await;
}

#[tokio::test]
pub async fn user_can_delete_a_habit() {
    let app = spawn_app().await;
    let (access_token, _, _) = user_signs_up(&app).await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;

    let habit_categories = user_gets_habits(&app, &access_token).await;
    assert!(habit_categories.is_empty());

    let habit_id = user_creates_a_habit(&app, &access_token, habit_category_id).await;

    let habit_categories = user_gets_habits(&app, &access_token).await;
    assert!(!habit_categories.is_empty());

    user_deletes_a_habit(&app, &access_token, habit_id).await;

    let habit_categories = user_gets_habits(&app, &access_token).await;
    assert!(habit_categories.is_empty());
}
