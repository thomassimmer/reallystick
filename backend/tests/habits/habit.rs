use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use chrono::Utc;
use reallystick::{
    core::helpers::mock_now::override_now,
    features::habits::structs::{
        models::{habit::HabitData, habit_statistics::HabitStatistics},
        responses::habit::{HabitResponse, HabitStatisticsResponse, HabitsResponse},
    },
};
use serde_json::json;
use std::{
    collections::{HashMap, HashSet},
    time::Duration,
};
use uuid::Uuid;

use crate::{
    auth::{login::user_logs_in, signup::user_signs_up, token::user_refreshes_token},
    challenges::{
        challenge::user_creates_a_challenge,
        challenge_daily_tracking::user_creates_a_challenge_daily_tracking,
    },
    habits::{
        habit_category::user_creates_a_habit_category,
        habit_daily_tracking::{
            user_creates_a_habit_daily_tracking, user_gets_habit_daily_trackings,
        },
        habit_participation::{user_creates_a_habit_participation, user_gets_habit_participations},
        unit::user_creates_a_unit,
    },
    helpers::spawn_app,
};

pub async fn user_creates_a_habit(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_category_id: Uuid,
    unit_ids: HashSet<Uuid>,
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
            "unit_ids": unit_ids
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
    unit_ids: HashSet<Uuid>,
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
            "reviewed": true,
            "unit_ids": unit_ids
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

pub async fn user_gets_habit_statistics(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<HabitStatistics> {
    let req = test::TestRequest::get()
        .uri("/api/habit-statistics/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitStatisticsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_STATISTICS_FETCHED");
    response.statistics
}

pub async fn user_create_two_habits_to_merge(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    habit_category_id: Uuid,
    units_ids: Vec<Uuid>,
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
            "unit_ids": units_ids
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
            "unit_ids": units_ids
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
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let unit_id = user_creates_a_unit(&app, &access_token).await;

    let (access_token, _, _) = user_signs_up(&app, None).await;

    let habits = user_gets_habits(&app, &access_token).await;
    assert!(habits.is_empty());

    let habit_id = user_creates_a_habit(
        &app,
        &access_token,
        habit_category_id,
        HashSet::from([unit_id]),
    )
    .await;

    user_creates_a_habit_participation(&app, &access_token, habit_id).await;

    let habits = user_gets_habits(&app, &access_token).await;
    assert_eq!(habits.len(), 1);

    // Before it has been reviewed, other users can't see it
    let (access_token, _, _) = user_signs_up(&app, Some("testusername2")).await;

    let habits = user_gets_habits(&app, &access_token).await;
    assert!(habits.is_empty());

    // Admin reviews it
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    user_updates_a_habit(
        &app,
        &access_token,
        habit_category_id,
        habit_id,
        HashSet::from([unit_id]),
    )
    .await;

    // Both users can see it
    let (access_token, _) = user_logs_in(&app, "testusername", "password1_").await;
    let habits = user_gets_habits(&app, &access_token).await;
    assert_eq!(habits.len(), 1);

    let (access_token, _) = user_logs_in(&app, "testusername2", "password1_").await;
    let habits = user_gets_habits(&app, &access_token).await;
    assert_eq!(habits.len(), 1);
}

#[tokio::test]
pub async fn admin_user_can_update_a_habit() {
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
    user_updates_a_habit(
        app,
        &access_token,
        habit_category_id,
        habit_id,
        HashSet::from([unit_id]),
    )
    .await;
}

#[tokio::test]
pub async fn admin_user_can_delete_a_habit() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;

    let habit_categories = user_gets_habits(&app, &access_token).await;
    assert!(habit_categories.is_empty());

    let unit_id = user_creates_a_unit(&app, &access_token).await;

    let habit_id = user_creates_a_habit(
        &app,
        &access_token,
        habit_category_id,
        HashSet::from([unit_id]),
    )
    .await;

    let habit_categories = user_gets_habits(&app, &access_token).await;
    assert!(!habit_categories.is_empty());

    user_deletes_a_habit(&app, &access_token, habit_id).await;

    let habit_categories = user_gets_habits(&app, &access_token).await;
    assert!(habit_categories.is_empty());
}

#[tokio::test]
pub async fn normal_user_can_not_merge_two_habits() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let unit_id = user_creates_a_unit(&app, &access_token).await;

    let (access_token, _, _) = user_signs_up(&app, None).await;
    let (first_habit_id, second_habit_id) =
        user_create_two_habits_to_merge(&app, &access_token, habit_category_id, vec![unit_id])
            .await;

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
            "reviewed": true,
            "unit_ids": vec![unit_id]
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
    let unit_id = user_creates_a_unit(&app, &access_token).await;

    let (first_habit_id, second_habit_id) =
        user_create_two_habits_to_merge(&app, &access_token, habit_category_id, vec![unit_id])
            .await;

    // We create a habit daily tracking with the second habit to check that it will use the first habit after merging
    user_creates_a_habit_daily_tracking(&app, &access_token, second_habit_id, unit_id).await;
    let habit_daily_trackings = user_gets_habit_daily_trackings(&app, &access_token).await;
    assert_eq!(habit_daily_trackings.len(), 1);
    assert_eq!(habit_daily_trackings[0].habit_id, second_habit_id);

    // Same for habit participation
    user_creates_a_habit_participation(&app, &access_token, first_habit_id).await; // to ensure unique constraint is considered
    user_creates_a_habit_participation(&app, &access_token, second_habit_id).await;
    let habit_participations = user_gets_habit_participations(&app, &access_token).await;
    assert_eq!(habit_participations.len(), 2);
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
            "reviewed": true,
            "unit_ids": vec![unit_id]
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
    assert_eq!(habit_daily_trackings.len(), 1);
    assert_eq!(habit_daily_trackings[0].habit_id, first_habit_id);

    let habit_participations = user_gets_habit_participations(&app, &access_token).await;
    assert_eq!(habit_participations.len(), 1);
    assert_eq!(habit_participations[0].habit_id, first_habit_id);
}

#[tokio::test]
pub async fn user_can_get_habit_statistics() {
    let app = spawn_app().await;
    let (access_token, refresh_token) = user_logs_in(&app, "thomas", "").await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let unit_id = user_creates_a_unit(&app, &access_token).await;
    let habit_id = user_creates_a_habit(
        &app,
        &access_token,
        habit_category_id,
        HashSet::from([unit_id]),
    )
    .await;

    let req = test::TestRequest::post()
        .uri("/api/users/me")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "username": "thomas",
            "locale": "fr",
            "theme": "light",
            "has_seen_questions": true,
            "age_category": "20-25",
            "gender": "male",
            "continent": "europe",
            "country": "france",
            "region": None::<String>,
            "activity": None::<String>,
            "financial_situation": "poor",
            "lives_in_urban_area": true,
            "relationship_status": "single",
            "level_of_education": "1",
            "has_children": false,
        }))
        .to_request();
    let response = test::call_service(&app, req).await;
    assert_eq!(200, response.status().as_u16());

    let statistics = user_gets_habit_statistics(&app, &access_token).await;

    assert_eq!(statistics.len(), 1);
    assert_eq!(statistics[0].participants_count, 0);

    user_creates_a_habit_participation(&app, &access_token, habit_id).await;

    // We need to wait one hour for statistics to change

    let statistics = user_gets_habit_statistics(&app, &access_token).await;

    assert_eq!(statistics.len(), 1);
    assert_eq!(statistics[0].participants_count, 0);

    override_now(Some(
        (Utc::now() + Duration::new(59 * 60, 1)).fixed_offset(),
    ));

    let (access_token, _) = user_refreshes_token(&app, &refresh_token).await;

    let statistics = user_gets_habit_statistics(&app, &access_token).await;

    assert_eq!(statistics.len(), 1);
    assert_eq!(statistics[0].participants_count, 0);

    override_now(Some(
        (Utc::now() + Duration::new(61 * 60, 1)).fixed_offset(),
    ));

    let statistics = user_gets_habit_statistics(&app, &access_token).await;

    assert_eq!(statistics.len(), 1);
    assert_eq!(statistics[0].participants_count, 1);
    assert_eq!(statistics[0].top_activities, HashSet::from([]));
    assert_eq!(
        statistics[0].top_ages,
        HashSet::from([("20-25".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_countries,
        HashSet::from([("france".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_financial_situations,
        HashSet::from([("poor".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_gender,
        HashSet::from([("male".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_has_children,
        HashSet::from([("No".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_levels_of_education,
        HashSet::from([("1".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_lives_in_urban_area,
        HashSet::from([("Yes".to_string(), 1)])
    );
    assert_eq!(statistics[0].top_regions, HashSet::from([]));
    assert_eq!(
        statistics[0].top_relationship_statuses,
        HashSet::from([("single".to_string(), 1)])
    );
    assert_eq!(statistics[0].challenges, Vec::<String>::new());

    let (access_token, refresh_token, _) = user_signs_up(&app, None).await;

    let req = test::TestRequest::post()
        .uri("/api/users/me")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "username": "testusername",
            "locale": "fr",
            "theme": "light",
            "has_seen_questions": true,
            "age_category": "25-30",
            "gender": "female",
            "continent": "europe",
            "country": "england",
            "region": None::<String>,
            "activity": "worker",
            "financial_situation": "poor",
            "lives_in_urban_area": true,
            "relationship_status": "couple",
            "level_of_education": "2",
            "has_children": true,
        }))
        .to_request();
    let response = test::call_service(&app, req).await;
    assert_eq!(200, response.status().as_u16());

    user_creates_a_habit_participation(&app, &access_token, habit_id).await;

    let challenge_id = user_creates_a_challenge(&app, &access_token).await;
    user_creates_a_challenge_daily_tracking(&app, &access_token, challenge_id, habit_id, unit_id)
        .await;

    // We need to wait another hour before seing changes in statistics

    override_now(Some(
        (Utc::now() + Duration::new(119 * 60, 1)).fixed_offset(),
    ));

    let (access_token, _) = user_refreshes_token(&app, &refresh_token).await;

    let statistics = user_gets_habit_statistics(&app, &access_token).await;

    assert_eq!(statistics.len(), 1);
    assert_eq!(statistics[0].participants_count, 1);
    assert_eq!(statistics[0].top_activities, HashSet::from([]));
    assert_eq!(
        statistics[0].top_ages,
        HashSet::from([("20-25".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_countries,
        HashSet::from([("france".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_financial_situations,
        HashSet::from([("poor".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_gender,
        HashSet::from([("male".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_has_children,
        HashSet::from([("No".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_levels_of_education,
        HashSet::from([("1".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_lives_in_urban_area,
        HashSet::from([("Yes".to_string(), 1)])
    );
    assert_eq!(statistics[0].top_regions, HashSet::from([]));
    assert_eq!(
        statistics[0].top_relationship_statuses,
        HashSet::from([("single".to_string(), 1)])
    );
    assert_eq!(statistics[0].challenges, Vec::<String>::new());

    override_now(Some(
        (Utc::now() + Duration::new(121 * 60, 1)).fixed_offset(),
    ));

    let statistics = user_gets_habit_statistics(&app, &access_token).await;

    assert_eq!(statistics.len(), 1);
    assert_eq!(statistics[0].participants_count, 2);
    assert_eq!(
        statistics[0].top_activities,
        HashSet::from([("worker".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_ages,
        HashSet::from([("25-30".to_string(), 1), ("20-25".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_countries,
        HashSet::from([("france".to_string(), 1), ("england".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_financial_situations,
        HashSet::from([("poor".to_string(), 2)])
    );
    assert_eq!(
        statistics[0].top_gender,
        HashSet::from([("male".to_string(), 1), ("female".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_has_children,
        HashSet::from([("No".to_string(), 1), ("Yes".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_levels_of_education,
        HashSet::from([("1".to_string(), 1), ("2".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].top_lives_in_urban_area,
        HashSet::from([("Yes".to_string(), 2)])
    );
    assert_eq!(statistics[0].top_regions, HashSet::from([]));
    assert_eq!(
        statistics[0].top_relationship_statuses,
        HashSet::from([("single".to_string(), 1), ("couple".to_string(), 1)])
    );
    assert_eq!(
        statistics[0].challenges,
        Vec::<String>::from([challenge_id.to_string()])
    );
}
