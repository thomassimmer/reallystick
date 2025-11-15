use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use api::{
    core::structs::responses::GenericResponse,
    features::profile::application::dto::{
        requests::SetUserPasswordRequest, responses::UserResponse,
    },
};
use sqlx::PgPool;

use crate::{
    auth::{
        login::user_logs_in,
        recovery::recover_account_without_2fa_enabled::user_recovers_account_without_2fa_enabled,
        recovery_code::{
            encrypt_private_key_with_password, generate_key_pair, generate_recovery_code,
            user_saves_recovery_code,
        },
        signup::user_signs_up,
    },
    helpers::spawn_app,
};

pub async fn user_sets_password(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    new_password: &str,
    private_key: &str,
) {
    let (private_key_encrypted, salt_used_to_derive_key_from_password) =
        encrypt_private_key_with_password(private_key, new_password);

    let req = test::TestRequest::post()
        .uri("/api/users/set-password")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(SetUserPasswordRequest {
            new_password: new_password.to_string(),
            private_key_encrypted,
            salt_used_to_derive_key_from_password,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: UserResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PASSWORD_CHANGED");
}

#[sqlx::test]
pub async fn user_can_set_password_after_account_recovery(pool: PgPool) {
    let app = spawn_app(pool).await;
    let (access_token, _) = user_signs_up(&app, None).await;
    let (private_key, _) = generate_key_pair();
    let recovery_code = generate_recovery_code();

    user_saves_recovery_code(&app, &access_token, &recovery_code, &private_key).await;

    let (access_token, _) = user_recovers_account_without_2fa_enabled(&app, &recovery_code).await;

    user_sets_password(&app, &access_token, "new_password1_", &private_key).await;
    user_logs_in(&app, "testusername", "new_password1_").await;
}

#[sqlx::test]
pub async fn user_cannot_set_password_if_its_not_expired(pool: PgPool) {
    let app = spawn_app(pool).await;
    let (access_token, _) = user_signs_up(&app, None).await;

    let (private_key, _) = generate_key_pair();
    let new_password = "new_password1_".to_string();

    let (private_key_encrypted, salt_used_to_derive_key_from_password) =
        encrypt_private_key_with_password(&private_key, &new_password);

    let req = test::TestRequest::post()
        .uri("/api/users/set-password")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(SetUserPasswordRequest {
            new_password: new_password.clone(),
            private_key_encrypted,
            salt_used_to_derive_key_from_password,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(403, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: GenericResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PASSWORD_NOT_EXPIRED");
}
