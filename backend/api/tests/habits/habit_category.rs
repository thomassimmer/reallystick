use std::collections::HashMap;

use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use api::features::habits::structs::{
    models::habit_category::HabitCategoryData,
    responses::habit_category::{HabitCategoriesResponse, HabitCategoryResponse},
};
use serde_json::json;
use sqlx::PgPool;
use uuid::Uuid;

use crate::{auth::login::user_logs_in, helpers::spawn_app};

pub async fn user_creates_a_habit_category(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Uuid {
    let req = test::TestRequest::post()
        .uri("/api/habit-categories/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(serde_json::json!({
            "name": HashMap::from([("en", "Learning languages")]),
            "icon": "english_icon".to_string(),
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitCategoryResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_CATEGORY_CREATED");
    assert!(response.habit_category.is_some());

    response.habit_category.unwrap().id
}

pub async fn user_updates_a_habit_category(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_category_id: Uuid,
) {
    let req = test::TestRequest::put()
        .uri(&format!("/api/habit-categories/{}", habit_category_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(serde_json::json!({
            "name": HashMap::from([("en", "Learning languages"), ("fr", "Apprendre une langue")]),
            "icon": "english_icon".to_string(),
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitCategoryResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_CATEGORY_UPDATED");
    assert!(response.habit_category.is_some());
    assert_eq!(
        response.habit_category.unwrap().name,
        json!(HashMap::from([
            ("en", "Learning languages"),
            ("fr", "Apprendre une langue")
        ]))
        .to_string()
    );
}

pub async fn user_deletes_a_habit_category(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_category_id: Uuid,
) {
    let req = test::TestRequest::delete()
        .uri(&format!("/api/habit-categories/{}", habit_category_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitCategoryResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_CATEGORY_DELETED");
    assert!(response.habit_category.is_none());
}

pub async fn user_gets_habit_categories(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<HabitCategoryData> {
    let req = test::TestRequest::get()
        .uri("/api/habit-categories/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitCategoriesResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_CATEGORIES_FETCHED");
    response.habit_categories
}

#[sqlx::test]
pub async fn admin_user_can_create_a_habit_category(pool: PgPool) {
    let app = spawn_app(pool).await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;

    let habit_categories = user_gets_habit_categories(&app, &access_token).await;
    assert!(habit_categories.is_empty());

    user_creates_a_habit_category(&app, &access_token).await;

    let habit_categories = user_gets_habit_categories(app, &access_token).await;
    assert!(!habit_categories.is_empty());
}

#[sqlx::test]
pub async fn admin_user_can_update_a_habit_category(pool: PgPool) {
    let app = spawn_app(pool).await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;

    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    user_updates_a_habit_category(app, &access_token, habit_category_id).await;
}

#[sqlx::test]
pub async fn admin_user_can_delete_a_habit_category(pool: PgPool) {
    let app = spawn_app(pool).await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;

    let habit_categories = user_gets_habit_categories(&app, &access_token).await;
    assert!(habit_categories.is_empty());

    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;

    let habit_categories = user_gets_habit_categories(&app, &access_token).await;
    assert!(!habit_categories.is_empty());

    user_deletes_a_habit_category(&app, &access_token, habit_category_id).await;

    let habit_categories = user_gets_habit_categories(&app, &access_token).await;
    assert!(habit_categories.is_empty());
}
