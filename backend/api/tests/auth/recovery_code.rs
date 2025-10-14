use crate::helpers::spawn_app;
use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use api::features::auth::structs::{
    requests::SaveRecoveryCodeRequest, responses::SaveRecoveryCodeResponse,
};
use rand::{distributions::Alphanumeric, Rng};

use crate::auth::signup::user_signs_up;

/// Generate an ECC key pair
pub fn generate_key_pair() -> (String, String) {
    (String::new(), String::new())
}

pub fn encrypt_private_key_with_password(_private_key: &str, _password: &str) -> (String, String) {
    (String::new(), String::new())
}

pub fn generate_recovery_code() -> String {
    let recovery_code: String = rand::thread_rng()
        .sample_iter(&Alphanumeric)
        .take(16)
        .map(char::from)
        .collect();

    recovery_code
}

pub async fn user_saves_recovery_code(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    recovery_code: &str,
    private_key: &str,
) {
    let (private_key_encrypted, salt_used_to_derive_key_from_recovery_code) =
        encrypt_private_key_with_password(private_key, recovery_code);

    let req = test::TestRequest::post()
        .uri("/api/auth/save-recovery-code")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(SaveRecoveryCodeRequest {
            recovery_code: recovery_code.to_string(),
            private_key_encrypted,
            salt_used_to_derive_key_from_recovery_code,
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(201, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: SaveRecoveryCodeResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "NEW_RECOVERY_CODE_SAVED")
}

#[tokio::test]
async fn user_can_save_recovery_code() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;
    let (private_key, _) = generate_key_pair();
    let recovery_code = generate_recovery_code();
    user_saves_recovery_code(&app, &access_token, &recovery_code, &private_key).await;
}
