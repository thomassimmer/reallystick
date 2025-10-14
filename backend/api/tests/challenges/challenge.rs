use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use chrono::Utc;
use api::{
    core::{helpers::mock_now::override_now, structs::responses::GenericResponse},
    features::{
        challenges::structs::{
            models::{challenge::ChallengeData, challenge_statistics::ChallengeStatistics},
            responses::challenge::{
                ChallengeResponse, ChallengeStatisticsResponse, ChallengesResponse,
            },
        },
        profile::structs::requests::UserUpdateRequest,
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
    challenges::challenge_participation::user_creates_a_challenge_participation,
    habits::{
        habit::user_creates_a_habit, habit_category::user_creates_a_habit_category,
        unit::user_creates_a_unit,
    },
    helpers::spawn_app,
};

use super::challenge_daily_tracking::{
    user_creates_a_challenge_daily_tracking, user_gets_challenge_daily_trackings,
};

pub async fn user_creates_a_challenge(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Uuid {
    let req = test::TestRequest::post()
        .uri("/api/challenges/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "name": HashMap::from([("en", "English")]),
            "description": HashMap::from([(
                "en",
                "Our goal is to speak English fluently in 30 days!"
            )]),
            "icon": "english_icon".to_string(),
            "start_date": Utc::now(),
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_CREATED");
    assert!(response.challenge.is_some());

    response.challenge.unwrap().id
}

pub async fn user_duplicates_a_challenge(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_id: Uuid,
) -> Uuid {
    let req = test::TestRequest::get()
        .uri(&format!("/api/challenges/duplicate/{}", challenge_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_CREATED");
    assert!(response.challenge.is_some());

    response.challenge.unwrap().id
}

pub async fn user_updates_a_challenge(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_id: Uuid,
) {
    let req = test::TestRequest::put()
        .uri(&format!("/api/challenges/{}", challenge_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "name": HashMap::from([("en", "English"), ("fr", "Anglais")]),
            "description": HashMap::from([(
                "en",
                "Our goal is to speak English fluently in 30 days!"
            )]),
            "icon": "english_icon".to_string(),
            "start_date": Utc::now(),
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_UPDATED");
    assert!(response.challenge.is_some());
    assert_eq!(
        response.challenge.clone().unwrap().name,
        json!(HashMap::from([("en", "English"), ("fr", "Anglais")])).to_string()
    );
}

pub async fn user_deletes_a_challenge(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    challenge_id: Uuid,
) {
    let req = test::TestRequest::delete()
        .uri(&format!("/api/challenges/{}", challenge_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_DELETED");
    assert!(response.challenge.is_none());
}

pub async fn user_gets_challenges(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<ChallengeData> {
    let req = test::TestRequest::get()
        .uri("/api/challenges/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengesResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGES_FETCHED");
    response.challenges
}

pub async fn user_gets_challenge_statistics(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<ChallengeStatistics> {
    let req = test::TestRequest::get()
        .uri("/api/challenge-statistics/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: ChallengeStatisticsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "CHALLENGE_STATISTICS_FETCHED");
    response.statistics
}

#[tokio::test]
pub async fn user_can_create_a_challenge() {
    let app = spawn_app().await;

    let (access_token, _) = user_signs_up(&app, None).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert!(challenges.is_empty());

    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert_eq!(challenges.len(), 1);

    let (access_token, _) = user_signs_up(&app, Some("testusername2")).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert_eq!(challenges.len(), 1);

    user_creates_a_challenge_participation(&app, &access_token, challenge_id).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert_eq!(challenges.len(), 1);
}

#[tokio::test]
pub async fn user_can_duplicate_a_challenge() {
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

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert!(challenges.is_empty());

    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let challenge_daily_tracking_id = user_creates_a_challenge_daily_tracking(
        &app,
        &access_token,
        challenge_id,
        habit_id,
        unit_id,
    )
    .await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert_eq!(challenges.len(), 1);

    let initial_challenge = &challenges[0];

    let challenge_daily_trackings =
        user_gets_challenge_daily_trackings(&app, &access_token, challenge_id).await;
    assert_eq!(challenge_daily_trackings.len(), 2);
    assert_eq!(challenge_daily_trackings[0].id, challenge_daily_tracking_id);
    assert_eq!(
        challenge_daily_trackings[0].challenge_id,
        initial_challenge.id
    );

    let (access_token, _) = user_signs_up(&app, None).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert_eq!(challenges.len(), 1);

    let duplicated_challenge_id =
        user_duplicates_a_challenge(&app, &access_token, challenge_id).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert_eq!(challenges.len(), 2);
    assert_eq!(challenges[1].id, duplicated_challenge_id);
    assert_eq!(challenges[1].name, initial_challenge.name);
    assert_eq!(challenges[1].description, initial_challenge.description);
    assert_ne!(challenges[1].creator, initial_challenge.creator);

    let challenge_daily_trackings =
        user_gets_challenge_daily_trackings(&app, &access_token, duplicated_challenge_id).await;
    assert_eq!(challenge_daily_trackings.len(), 2);
    assert_ne!(challenge_daily_trackings[0].id, challenge_daily_tracking_id);
    assert_eq!(
        challenge_daily_trackings[0].challenge_id,
        duplicated_challenge_id
    );
}

#[tokio::test]
pub async fn normal_user_cannot_update_a_challenge() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let (access_token, _) = user_signs_up(&app, Some("testusername2")).await;

    let req = test::TestRequest::put()
        .uri(&format!("/api/challenges/{}", challenge_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "name": HashMap::from([("en", "English"), ("fr", "Anglais")]),
            "description": HashMap::from([(
                "en",
                "Our goal is to speak English fluently in 30 days!"
            )]),
            "icon": "english_icon".to_string(),
            "start_date": Utc::now(),
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(403, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "INVALID_CHALLENGE_CREATOR");
}

#[tokio::test]
pub async fn creator_can_update_a_challenge() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;

    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    user_updates_a_challenge(app, &access_token, challenge_id).await;
}

#[tokio::test]
pub async fn admin_user_can_update_a_challenge() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;

    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    user_updates_a_challenge(app, &access_token, challenge_id).await;
}

#[tokio::test]
pub async fn normal_user_cannot_delete_a_challenge() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert!(challenges.is_empty());

    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert!(!challenges.is_empty());

    let (access_token, _) = user_signs_up(&app, Some("testusername2")).await;

    let req = test::TestRequest::delete()
        .uri(&format!("/api/challenges/{}", challenge_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(403, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "INVALID_CHALLENGE_CREATOR");
}

#[tokio::test]
pub async fn creator_can_delete_a_challenge() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert!(challenges.is_empty());

    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert!(!challenges.is_empty());

    user_deletes_a_challenge(&app, &access_token, challenge_id).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert!(!challenges.is_empty());
    assert!(challenges[0].deleted);
}

#[tokio::test]
pub async fn admin_user_can_delete_a_challenge() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert!(challenges.is_empty());

    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert!(!challenges.is_empty());

    user_deletes_a_challenge(&app, &access_token, challenge_id).await;

    let challenges = user_gets_challenges(&app, &access_token).await;
    assert!(!challenges.is_empty());
    assert!(challenges[0].deleted);
}

#[tokio::test]
pub async fn user_can_get_challenge_statistics() {
    let app = spawn_app().await;
    let (access_token, refresh_token) = user_logs_in(&app, "thomas", "").await;
    let challenge_id = user_creates_a_challenge(&app, &access_token).await;

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

    let statistics = user_gets_challenge_statistics(&app, &access_token).await;

    assert_eq!(statistics.len(), 1);
    assert_eq!(statistics[0].participants_count, 0);

    user_creates_a_challenge_participation(&app, &access_token, challenge_id).await;

    // We need to wait one hour for statistics to change

    let statistics = user_gets_challenge_statistics(&app, &access_token).await;

    assert_eq!(statistics.len(), 1);
    assert_eq!(statistics[0].participants_count, 0);

    override_now(Some(
        (Utc::now() + Duration::new(59 * 60, 1)).fixed_offset(),
    ));

    let (access_token, _) = user_refreshes_token(&app, &refresh_token).await;

    let statistics = user_gets_challenge_statistics(&app, &access_token).await;

    assert_eq!(statistics.len(), 1);
    assert_eq!(statistics[0].participants_count, 0);

    override_now(Some(
        (Utc::now() + Duration::new(61 * 60, 1)).fixed_offset(),
    ));

    let statistics = user_gets_challenge_statistics(&app, &access_token).await;

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

    user_creates_a_challenge_participation(&app, &access_token, challenge_id).await;

    // We need to wait another hour before seing changes in statistics

    override_now(Some(
        (Utc::now() + Duration::new(119 * 60, 1)).fixed_offset(),
    ));

    let (access_token, _) = user_refreshes_token(&app, &refresh_token).await;

    let statistics = user_gets_challenge_statistics(&app, &access_token).await;

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

    override_now(Some(
        (Utc::now() + Duration::new(121 * 60, 1)).fixed_offset(),
    ));

    let statistics = user_gets_challenge_statistics(&app, &access_token).await;

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
}
