use actix_http::Request;
use actix_web::body::MessageBody;
use actix_web::dev::{Service, ServiceResponse};
use actix_web::http::header::ContentType;
use actix_web::{test, Error};
use api::core::structs::responses::GenericResponse;
use api::features::auth::structs::responses::UserLoginResponse;

use crate::auth::recovery_code::{
    generate_key_pair, generate_recovery_code, user_saves_recovery_code,
};
use crate::auth::signup::user_signs_up;
use crate::helpers::spawn_app;
use crate::profile::profile::user_has_access_to_protected_route;

pub async fn user_recovers_account_without_2fa_enabled(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    recovery_code: &str,
) -> (String, String) {
    let req = test::TestRequest::post()
        .uri("/api/auth/recover")
        .insert_header(ContentType::json())
        .set_json(serde_json::json!({
            "username": "testusername",
            "recovery_code": recovery_code,
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: UserLoginResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "USER_LOGGED_IN_AFTER_ACCOUNT_RECOVERY");

    (response.access_token, response.refresh_token)
}

#[tokio::test]
async fn user_can_recover_account_without_2fa_enabled() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;
    let (private_key, _) = generate_key_pair();
    let recovery_code = generate_recovery_code();

    user_saves_recovery_code(&app, &access_token, &recovery_code, &private_key).await;

    let (access_token, _) = user_recovers_account_without_2fa_enabled(&app, &recovery_code).await;

    user_has_access_to_protected_route(&app, &access_token).await;
}

#[tokio::test]
async fn user_cannot_recover_account_without_2fa_enabled_with_wrong_code() {
    let app = spawn_app().await;
    user_signs_up(&app, None).await;
    let req = test::TestRequest::post()
        .uri("/api/auth/recover")
        .insert_header(ContentType::json())
        .set_json(serde_json::json!({
            "username": "testusername",
            "recovery_code": "wrong_recovery_code",
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(401, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "INVALID_USERNAME_OR_RECOVERY_CODE");
}

#[tokio::test]
async fn user_cannot_recover_account_without_2fa_enabled_with_wrong_username() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;
    let (private_key, _) = generate_key_pair();
    let recovery_code = generate_recovery_code();

    user_saves_recovery_code(&app, &access_token, &recovery_code, &private_key).await;

    let req = test::TestRequest::post()
        .uri("/api/auth/recover")
        .insert_header(ContentType::json())
        .set_json(serde_json::json!({
            "username": "wrong_username",
            "recovery_code": recovery_code,
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(401, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "INVALID_USERNAME_OR_RECOVERY_CODE");
}

#[tokio::test]
async fn user_cannot_recover_account_without_2fa_enabled_using_code_twice() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;

    let (private_key, _) = generate_key_pair();
    let recovery_code = generate_recovery_code();
    user_saves_recovery_code(&app, &access_token, &recovery_code, &private_key).await;

    let (access_token, _) = user_recovers_account_without_2fa_enabled(&app, &recovery_code).await;

    user_has_access_to_protected_route(&app, &access_token).await;

    let req = test::TestRequest::post()
        .uri("/api/auth/recover")
        .insert_header(ContentType::json())
        .set_json(serde_json::json!({
            "username": "testusername",
            "recovery_code": recovery_code,
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(401, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "INVALID_USERNAME_OR_RECOVERY_CODE");
}

#[tokio::test]
async fn user_cannot_login_with_old_password_after_recovery() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;
    let (private_key, _) = generate_key_pair();
    let recovery_code = generate_recovery_code();

    user_saves_recovery_code(&app, &access_token, &recovery_code, &private_key).await;

    let (access_token, _) = user_recovers_account_without_2fa_enabled(&app, &recovery_code).await;

    user_has_access_to_protected_route(&app, &access_token).await;

    let req = test::TestRequest::post()
        .uri("/api/auth/login")
        .insert_header(ContentType::json())
        .set_json(serde_json::json!({
        "username": "testusername",
        "password": "password1_",
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(403, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PASSWORD_MUST_BE_CHANGED");
}
