use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use reallystick::{
    core::structs::responses::GenericResponse,
    features::auth::structs::{requests::UserRegisterRequest, responses::UserSignupResponse},
};

use crate::{
    auth::recovery_code::{encrypt_private_key_with_password, generate_key_pair},
    helpers::spawn_app,
    profile::profile::user_has_access_to_protected_route,
};

pub async fn user_signs_up(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    username: Option<&str>,
) -> (String, String) {
    let username = username.unwrap_or("testusername");
    let password = "password1_".to_string();

    let (private_key, public_key) = generate_key_pair();
    let (private_key_encrypted, salt_used_to_derive_key_from_password) =
        encrypt_private_key_with_password(&private_key, &password);

    let req = test::TestRequest::post()
        .uri("/api/auth/signup")
        .insert_header(ContentType::json())
        .set_json(UserRegisterRequest {
            username: username.to_string(),
            password,
            locale: "en".to_string(),
            theme: "dark".to_string(),
            timezone: "America/New_York".to_string(),
            public_key,
            private_key_encrypted,
            salt_used_to_derive_key_from_password,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(201, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: UserSignupResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "USER_SIGNED_UP");

    (response.access_token, response.refresh_token)
}

#[tokio::test]
async fn user_can_signup() {
    let app = spawn_app().await;
    user_signs_up(&app, None).await;
}

#[tokio::test]
async fn registered_user_can_access_profile_information() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;

    // User can access a route protected by token authentication
    user_has_access_to_protected_route(&app, &access_token).await;
}

#[tokio::test]
async fn user_with_invalid_token_cannot_access_profile_information() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;

    // A wrong token would not work
    let wrong_access_token = access_token
        .chars()
        .enumerate()
        .map(|(i, c)| if i == 5 { 'x' } else { c })
        .collect::<String>();

    let req = test::TestRequest::get()
        .uri("/api/users/me")
        .insert_header((
            header::AUTHORIZATION,
            format!("Bearer {}", wrong_access_token),
        ))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(401, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "INVALID_ACCESS_TOKEN");
}

#[tokio::test]
async fn unauthenticated_user_cannot_access_profile_information() {
    let app = spawn_app().await;
    let req = test::TestRequest::get().uri("/api/users/me").to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(401, response.status().as_u16());
}

#[tokio::test]
async fn user_cannot_signup_with_existing_username() {
    let app = spawn_app().await;
    user_signs_up(&app, None).await;

    let password = "password1_".to_string();

    let (private_key, public_key) = generate_key_pair();
    let (private_key_encrypted, salt_used_to_derive_key_from_password) =
        encrypt_private_key_with_password(&private_key, &password);

    let req = test::TestRequest::post()
        .uri("/api/auth/signup")
        .insert_header(ContentType::json())
        .set_json(UserRegisterRequest {
            username: "testusername".to_string(),
            password,
            locale: "en".to_string(),
            theme: "dark".to_string(),
            timezone: "America/New_York".to_string(),
            public_key,
            private_key_encrypted,
            salt_used_to_derive_key_from_password,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(409, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "USER_ALREADY_EXISTS");
}

#[tokio::test]
async fn user_cannot_signup_with_short_password() {
    let app = spawn_app().await;

    let password = "passwor".to_string();

    let (private_key, public_key) = generate_key_pair();
    let (private_key_encrypted, salt_used_to_derive_key_from_password) =
        encrypt_private_key_with_password(&private_key, &password);

    let req = test::TestRequest::post()
        .uri("/api/auth/signup")
        .insert_header(ContentType::json())
        .set_json(UserRegisterRequest {
            username: "testusername".to_string(),
            password,
            locale: "en".to_string(),
            theme: "dark".to_string(),
            timezone: "America/New_York".to_string(),
            public_key,
            private_key_encrypted,
            salt_used_to_derive_key_from_password,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(401, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PASSWORD_TOO_SHORT");
}

#[tokio::test]
async fn user_cannot_signup_with_short_username() {
    let app = spawn_app().await;

    let password = "password1_".to_string();

    let (private_key, public_key) = generate_key_pair();
    let (private_key_encrypted, salt_used_to_derive_key_from_password) =
        encrypt_private_key_with_password(&private_key, &password);

    let req = test::TestRequest::post()
        .uri("/api/auth/signup")
        .insert_header(ContentType::json())
        .set_json(UserRegisterRequest {
            username: "te".to_string(),
            password,
            locale: "en".to_string(),
            theme: "dark".to_string(),
            timezone: "America/New_York".to_string(),
            public_key,
            private_key_encrypted,
            salt_used_to_derive_key_from_password,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(401, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "USERNAME_WRONG_SIZE");
}

#[tokio::test]
async fn user_cannot_signup_with_long_username() {
    let app = spawn_app().await;

    let password = "password1_".to_string();

    let (private_key, public_key) = generate_key_pair();
    let (private_key_encrypted, salt_used_to_derive_key_from_password) =
        encrypt_private_key_with_password(&private_key, &password);

    let req = test::TestRequest::post()
        .uri("/api/auth/signup")
        .insert_header(ContentType::json())
        .set_json(UserRegisterRequest {
            username: "testusernametestusernametestusername".to_string(),
            password,
            locale: "en".to_string(),
            theme: "dark".to_string(),
            timezone: "America/New_York".to_string(),
            public_key,
            private_key_encrypted,
            salt_used_to_derive_key_from_password,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(401, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "USERNAME_WRONG_SIZE");
}

#[tokio::test]
async fn user_cannot_signup_with_username_not_respecting_rules() {
    let app = spawn_app().await;

    let password = "password1_".to_string();

    let (private_key, public_key) = generate_key_pair();
    let (private_key_encrypted, salt_used_to_derive_key_from_password) =
        encrypt_private_key_with_password(&private_key, &password);

    let req = test::TestRequest::post()
        .uri("/api/auth/signup")
        .insert_header(ContentType::json())
        .set_json(UserRegisterRequest {
            username: "__x__".to_string(),
            password,
            locale: "en".to_string(),
            theme: "dark".to_string(),
            timezone: "America/New_York".to_string(),
            public_key,
            private_key_encrypted,
            salt_used_to_derive_key_from_password,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(401, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "USERNAME_NOT_RESPECTING_RULES");
}
