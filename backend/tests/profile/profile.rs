use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test::{self, init_service},
    Error,
};
use chrono::Utc;
use reallystick::{
    configuration::get_configuration,
    core::{
        helpers::{
            mock_now::override_now, translation::Translator,
            user_deletion::remove_users_marked_as_deleted,
        },
        structs::responses::GenericResponse,
    },
    features::{
        auth::structs::models::TokenCache,
        challenges::structs::models::challenge_statistics::ChallengeStatisticsCache,
        habits::structs::models::habit_statistics::HabitStatisticsCache,
        profile::structs::{
            models::{UserData, UserPublicDataCache},
            requests::UserUpdateRequest,
            responses::{DeleteAccountResponse, IsOtpEnabledResponse, UserResponse},
        },
    },
    startup::create_app,
};
use redis::Client;
use sqlx::{Pool, Postgres};
use std::{sync::Arc, time::Duration};
use uuid::Uuid;

use crate::{
    auth::{
        login::user_logs_in,
        otp::{user_generates_otp, user_verifies_otp},
        signup::user_signs_up,
    },
    helpers::{configure_database, spawn_app},
};

pub async fn user_has_access_to_protected_route(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> UserData {
    let req = test::TestRequest::get()
        .uri("/api/users/me")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: UserResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PROFILE_FETCHED");

    response.user
}

pub async fn user_deletes_its_account(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) {
    let req = test::TestRequest::delete()
        .uri("/api/users/me")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: DeleteAccountResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "ACCOUNT_DELETED");
}

pub async fn delete_user_marked_as_deleted(
    connection_pool: &Pool<Postgres>,
    redis_client: &Client,
) {
    assert!(
        remove_users_marked_as_deleted(&connection_pool, &redis_client)
            .await
            .is_ok()
    );
}

#[tokio::test]
pub async fn user_can_update_profile() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;

    user_has_access_to_protected_route(&app, &access_token).await;

    let req = test::TestRequest::post()
        .uri("/api/users/me")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(UserUpdateRequest {
            locale: "fr".to_string(),
            theme: "light".to_string(),
            timezone: "America/New_York".to_string(),
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
            has_seen_questions: false,
            notifications_enabled: false,
            notifications_for_private_messages_enabled: false,
            notifications_for_public_message_liked_enabled: false,
            notifications_for_public_message_replies_enabled: false,
            notifications_user_joined_your_challenge_enabled: false,
            notifications_user_duplicated_your_challenge_enabled: false,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: UserResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PROFILE_UPDATED");
    assert_eq!(response.user.locale, "fr");
    assert_eq!(response.user.theme, "light");
}

#[tokio::test]
pub async fn user_can_delete_account() {
    let configuration = {
        let mut c = get_configuration().expect("Failed to read configuration.");
        // Use a different database for each test case
        c.database.database_name = Uuid::new_v4().to_string();
        // Use a random OS port
        c.application.port = 0;
        c
    };

    let habit_statistics_cache = HabitStatisticsCache::default();
    let challenge_statistics_cache = ChallengeStatisticsCache::default();
    let token_cache = TokenCache::default();
    let user_public_data_cache = UserPublicDataCache::default();
    let redis_client = redis::Client::open("redis://redis:6379").unwrap();
    let translator = Arc::new(Translator::new());

    let connection_pool = configure_database(&configuration.database).await;
    let secret = configuration.application.secret;

    let app = init_service(create_app(
        connection_pool.clone(),
        secret.clone(),
        habit_statistics_cache,
        challenge_statistics_cache,
        token_cache,
        user_public_data_cache,
        redis_client.clone(),
        translator,
    ))
    .await;

    let (access_token, _) = user_signs_up(&app, None).await;

    user_deletes_its_account(&app, &access_token).await;

    // If user connects again before 7 days, the account deletion is cancelled.
    let (access_token, _) = user_logs_in(&app, "testusername", "password1_").await;

    // User can access a route protected by token authentication
    user_has_access_to_protected_route(&app, &access_token).await;

    user_deletes_its_account(&app, &access_token).await;

    override_now(Some(
        (Utc::now() + Duration::from_secs(7 * 60 * 60 * 24)).fixed_offset(),
    ));

    delete_user_marked_as_deleted(&connection_pool, &redis_client).await;

    // User can no longer access its account
    let req = test::TestRequest::post()
        .uri("/api/auth/login")
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
        "username": "testusername",
        "password": "password1_",
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(401, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "USER_HAS_BEEN_DELETED");
}

#[tokio::test]
pub async fn is_otp_enabled_for_user_that_activated_it() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;

    let req = test::TestRequest::post()
        .uri("/api/users/is-otp-enabled")
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "username": "testusername",
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: IsOtpEnabledResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "OTP_STATUS");
    assert_eq!(response.otp_enabled, false);

    // User only generates OTP
    user_generates_otp(&app, &access_token).await;

    let req = test::TestRequest::post()
        .uri("/api/users/is-otp-enabled")
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "username": "testusername",
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: IsOtpEnabledResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "OTP_STATUS");
    assert_eq!(response.otp_enabled, false);

    // User generates and validates OTP
    let otp_base32 = user_generates_otp(&app, &access_token).await;
    user_verifies_otp(&app, &access_token, &otp_base32).await;

    let req = test::TestRequest::post()
        .uri("/api/users/is-otp-enabled")
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "username": "testusername",
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: IsOtpEnabledResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "OTP_STATUS");
    assert_eq!(response.otp_enabled, true);
}
