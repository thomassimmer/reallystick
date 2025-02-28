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
use std::collections::HashMap;
use uuid::Uuid;

use crate::{
    auth::{login::user_logs_in, signup::user_signs_up},
    habits::habit_category::user_creates_a_habit_category,
    habits::habit_daily_tracking::{
        user_creates_a_habit_daily_tracking, user_gets_habit_daily_trackings,
    },
    habits::habit_participation::{
        user_creates_a_habit_participation, user_gets_habit_participations,
    },
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

pub async fn user_create_two_habits_to_merge(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_category_id: Uuid,
) -> (Uuid, Uuid) {
    let req = test::TestRequest::post()
        .uri("/api/habits/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "category_id": habit_category_id,
            "short_name": HashMap::from([("en", "Smoking")]),
            "long_name": HashMap::from([("en", "Quit smoking")]),
            "description": HashMap::from([(
                "en",
                "Our goal is to quit smoking!"
            )]),
            "icon": "smoking".to_string(),
        }))
        .to_request();

    let response = test::call_service(&app, req).await;
    let body = test::read_body(response).await;
    let response: HabitResponse = serde_json::from_slice(&body).unwrap();

    let first_habit_id = response.habit.unwrap().id;

    let req = test::TestRequest::post()
        .uri("/api/habits/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "category_id": habit_category_id,
            "short_name": HashMap::from([("fr", "Fumer")]),
            "long_name": HashMap::from([("fr", "Arrêter de fumer")]),
            "description": HashMap::from([(
                "fr",
                "Notre but est d'arrêter de fumer !"
            )]),
            "icon": "smoking".to_string(),
        }))
        .to_request();

    let response = test::call_service(&app, req).await;
    let body = test::read_body(response).await;
    let response: HabitResponse = serde_json::from_slice(&body).unwrap();

    let second_habit_id = response.habit.unwrap().id;

    (first_habit_id, second_habit_id)
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

#[tokio::test]
pub async fn normal_user_can_not_merge_two_habits() {
    let app = spawn_app().await;
    let (access_token, _, _) = user_signs_up(&app).await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;

    let (first_habit_id, second_habit_id) =
        user_create_two_habits_to_merge(&app, &access_token, habit_category_id).await;

    let req = test::TestRequest::post()
        .uri(&format!(
            "/api/habits/merge/{}/{}",
            second_habit_id, first_habit_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "new_habit_id": first_habit_id,
            "category_id": habit_category_id,
            "short_name": HashMap::from([("en", "Smoking"), ("fr", "Fumer")]),
            "long_name": HashMap::from([("en", "Quit smoking"), ("fr", "Arrêter de fumer")]),
            "description": HashMap::from([(
                "en",
                "Our goal is to speak English fluently!"
            ), (
                "fr",
                "Notre but est d'arrêter de fumer !"
            )]),
            "icon": "smoking".to_string(),
            "reviewed": true
        }))
        .to_request();

    let response = test::call_service(&app, req).await;

    assert_eq!(403, response.status().as_u16());
}

#[tokio::test]
pub async fn admin_user_can_merge_two_habits() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;

    let (first_habit_id, second_habit_id) =
        user_create_two_habits_to_merge(&app, &access_token, habit_category_id).await;

    // We create a habit daily tracking with the second habit to check that it will use the first habit after merging
    user_creates_a_habit_daily_tracking(&app, &access_token, second_habit_id).await;
    let habit_daily_trackings = user_gets_habit_daily_trackings(&app, &access_token).await;
    assert_eq!(habit_daily_trackings[0].habit_id, second_habit_id);

    // Same for habit participation
    user_creates_a_habit_participation(&app, &access_token, first_habit_id).await; // to ensure unique constraint is considered
    user_creates_a_habit_participation(&app, &access_token, second_habit_id).await;
    let habit_participations = user_gets_habit_participations(&app, &access_token).await;
    assert_eq!(habit_participations[0].habit_id, first_habit_id);
    assert_eq!(habit_participations[1].habit_id, second_habit_id);

    let req = test::TestRequest::post()
        .uri(&format!(
            "/api/habits/merge/{}/{}",
            second_habit_id, first_habit_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "new_habit_id": first_habit_id,
            "category_id": habit_category_id,
            "short_name": HashMap::from([("en", "Smoking"), ("fr", "Fumer")]),
            "long_name": HashMap::from([("en", "Quit smoking"), ("fr", "Arrêter de fumer")]),
            "description": HashMap::from([(
                "en",
                "Our goal is to speak English fluently!"
            ), (
                "fr",
                "Notre but est d'arrêter de fumer !"
            )]),
            "icon": "smoking".to_string(),
            "reviewed": true
        }))
        .to_request();

    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.habit.clone().unwrap().id, first_habit_id);
    assert_eq!(
        response.habit.clone().unwrap().short_name,
        json!(HashMap::from([("en", "Smoking"), ("fr", "Fumer")])).to_string()
    );
    assert_eq!(
        response.habit.clone().unwrap().long_name,
        json!(HashMap::from([
            ("en", "Quit smoking"),
            ("fr", "Arrêter de fumer")
        ]))
        .to_string()
    );
    assert_eq!(
        response.habit.clone().unwrap().description,
        json!(HashMap::from([
            ("en", "Our goal is to speak English fluently!"),
            ("fr", "Notre but est d'arrêter de fumer !")
        ]))
        .to_string()
    );

    let habit_daily_trackings = user_gets_habit_daily_trackings(&app, &access_token).await;
    assert_eq!(habit_daily_trackings[0].habit_id, first_habit_id);

    let habit_participations = user_gets_habit_participations(&app, &access_token).await;
    assert_eq!(habit_participations[0].habit_id, first_habit_id);
}
