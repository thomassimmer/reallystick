use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use api::{
    core::helpers::mock_now::override_now,
    features::{
        habits::{
            application::dto::{
                requests::habit::{HabitCreateRequest, HabitUpdateRequest},
                responses::habit::{HabitResponse, HabitStatisticsResponse, HabitsResponse},
            },
            domain::entities::{habit::HabitData, habit_statistics::HabitStatistics},
        },
        profile::application::dto::requests::UserUpdateRequest,
    },
};
use chrono::Utc;
use serde_json::json;
use sqlx::PgPool;
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
        .set_json(HabitCreateRequest {
            category_id: habit_category_id,
            name: HashMap::from([("en".to_string(), "English".to_string())]),
            description: HashMap::from([(
                "en".to_string(),
                "Our goal is to speak English fluently!".to_string(),
            )]),
            icon: "english_icon".to_string(),
            unit_ids,
        })
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
        .set_json(HabitUpdateRequest {
            category_id: habit_category_id,
            name: HashMap::from([
                ("en".to_string(), "English".to_string()),
                ("fr".to_string(), "Anglais".to_string()),
            ]),
            description: HashMap::from([(
                "en".to_string(),
                "Our goal is to speak English fluently!".to_string(),
            )]),
            icon: "english_icon".to_string(),
            reviewed: true,
            unit_ids,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "HABIT_UPDATED");
    assert!(response.habit.is_some());
    assert_eq!(
        response.habit.clone().unwrap().name,
        json!(HashMap::from([("en", "English"), ("fr", "Anglais")])).to_string()
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
        .set_json(HabitCreateRequest {
            category_id: habit_category_id,
            name: HashMap::from([("en".to_string(), "Smoking".to_string())]),
            description: HashMap::from([(
                "en".to_string(),
                "Our goal is to quit smoking!".to_string(),
            )]),
            icon: "smoking".to_string(),
            unit_ids: HashSet::from_iter(units_ids.clone()),
        })
        .to_request();

    let response = test::call_service(&app, req).await;
    let body = test::read_body(response).await;
    let response: HabitResponse = serde_json::from_slice(&body).unwrap();

    let first_habit_id = response.habit.unwrap().id;

    let req = test::TestRequest::post()
        .uri("/api/habits/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(HabitCreateRequest {
            category_id: habit_category_id,
            name: HashMap::from([("fr".to_string(), "Fumer".to_string())]),
            description: HashMap::from([(
                "fr".to_string(),
                "Notre but est d'arrêter de fumer !".to_string(),
            )]),
            icon: "smoking".to_string(),
            unit_ids: HashSet::from_iter(units_ids),
        })
        .to_request();

    let response = test::call_service(&app, req).await;
    let body = test::read_body(response).await;
    let response: HabitResponse = serde_json::from_slice(&body).unwrap();

    let second_habit_id = response.habit.unwrap().id;

    (first_habit_id, second_habit_id)
}

#[sqlx::test]
pub async fn user_can_create_a_habit(pool: PgPool) {
    let app = spawn_app(pool).await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let unit_id = user_creates_a_unit(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;

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
    let (access_token, _) = user_signs_up(&app, Some("testusername2")).await;

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

#[sqlx::test]
pub async fn admin_user_can_update_a_habit(pool: PgPool) {
    let app = spawn_app(pool).await;
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

#[sqlx::test]
pub async fn admin_user_can_delete_a_habit(pool: PgPool) {
    let app = spawn_app(pool).await;
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

#[sqlx::test]
pub async fn normal_user_can_not_merge_two_habits(pool: PgPool) {
    let app = spawn_app(pool).await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let habit_category_id = user_creates_a_habit_category(&app, &access_token).await;
    let unit_id = user_creates_a_unit(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, None).await;
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
        .set_json(HabitUpdateRequest {
            category_id: habit_category_id,
            name: HashMap::from([
                ("en".to_string(), "Smoking".to_string()),
                ("fr".to_string(), "Fumer".to_string()),
            ]),
            description: HashMap::from([
                (
                    "en".to_string(),
                    "Our goal is to speak English fluently!".to_string(),
                ),
                (
                    "fr".to_string(),
                    "Notre but est d'arrêter de fumer !".to_string(),
                ),
            ]),
            icon: "smoking".to_string(),
            reviewed: true,
            unit_ids: HashSet::from([unit_id]),
        })
        .to_request();

    let response = test::call_service(&app, req).await;

    assert_eq!(403, response.status().as_u16());
}

#[sqlx::test]
pub async fn admin_user_can_merge_two_habits(pool: PgPool) {
    let app = spawn_app(pool).await;
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
        .set_json(HabitUpdateRequest {
            category_id: habit_category_id,
            name: HashMap::from([
                ("en".to_string(), "Smoking".to_string()),
                ("fr".to_string(), "Fumer".to_string()),
            ]),
            description: HashMap::from([
                (
                    "en".to_string(),
                    "Our goal is to speak English fluently!".to_string(),
                ),
                (
                    "fr".to_string(),
                    "Notre but est d'arrêter de fumer !".to_string(),
                ),
            ]),
            icon: "smoking".to_string(),
            reviewed: true,
            unit_ids: HashSet::from([unit_id]),
        })
        .to_request();

    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: HabitResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.habit.clone().unwrap().id, first_habit_id);
    assert_eq!(
        response.habit.clone().unwrap().name,
        json!(HashMap::from([("en", "Smoking"), ("fr", "Fumer")])).to_string()
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

#[sqlx::test]
pub async fn user_can_get_habit_statistics(pool: PgPool) {
    let app = spawn_app(pool).await;
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
        .set_json(UserUpdateRequest {
            locale: "fr".to_string(),
            theme: "light".to_string(),
            timezone: "America/New_York".to_string(),
            has_seen_questions: true,
            age_category: Some("20-25".to_string()),
            gender: Some("male".to_string()),
            continent: Some("europe".to_string()),
            country: Some("france".to_string()),
            region: None::<String>,
            activity: None::<String>,
            financial_situation: Some("poor".to_string()),
            lives_in_urban_area: Some(true),
            relationship_status: Some("single".to_string()),
            level_of_education: Some("1".to_string()),
            has_children: Some(false),
            notifications_enabled: true,
            notifications_for_private_messages_enabled: true,
            notifications_for_public_message_liked_enabled: true,
            notifications_for_public_message_replies_enabled: true,
            notifications_user_joined_your_challenge_enabled: true,
            notifications_user_duplicated_your_challenge_enabled: true,
        })
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

    let (access_token, refresh_token) = user_signs_up(&app, None).await;

    let req = test::TestRequest::post()
        .uri("/api/users/me")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(UserUpdateRequest {
            locale: "fr".to_string(),
            theme: "light".to_string(),
            timezone: "America/New_York".to_string(),
            has_seen_questions: true,
            age_category: Some("25-30".to_string()),
            gender: Some("female".to_string()),
            continent: Some("europe".to_string()),
            country: Some("england".to_string()),
            region: None::<String>,
            activity: Some("worker".to_string()),
            financial_situation: Some("poor".to_string()),
            lives_in_urban_area: Some(true),
            relationship_status: Some("couple".to_string()),
            level_of_education: Some("2".to_string()),
            has_children: Some(true),
            notifications_enabled: true,
            notifications_for_private_messages_enabled: true,
            notifications_for_public_message_liked_enabled: true,
            notifications_for_public_message_replies_enabled: true,
            notifications_user_joined_your_challenge_enabled: true,
            notifications_user_duplicated_your_challenge_enabled: true,
        })
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
