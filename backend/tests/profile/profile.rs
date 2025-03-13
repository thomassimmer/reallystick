use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use reallystick::features::profile::structs::{
    models::UserData,
    requests::UserUpdateRequest,
    responses::{DeleteAccountResponse, IsOtpEnabledResponse, UserResponse},
};

use crate::{
    auth::{
        otp::{user_generates_otp, user_verifies_otp},
        signup::user_signs_up,
    },
    helpers::spawn_app,
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
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;

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
