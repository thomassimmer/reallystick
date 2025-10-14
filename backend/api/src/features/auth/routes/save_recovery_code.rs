use actix_web::{
    post,
    web::{self, ReqData},
    HttpResponse, Responder,
};
use argon2::{password_hash::SaltString, Argon2, PasswordHasher};
use rand::rngs::OsRng;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

use crate::{
    core::constants::errors::AppError,
    features::auth::{
        helpers::recovery_code::{self, delete_recovery_code_for_user},
        structs::{
            models::{Claims, RecoveryCode},
            requests::SaveRecoveryCodeRequest,
            responses::SaveRecoveryCodeResponse,
        },
    },
};

#[post("/save-recovery-code")]
pub async fn save_recovery_code(
    body: web::Json<SaveRecoveryCodeRequest>,
    pool: web::Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response())
        }
    };

    let delete_current_recovery_code_result =
        delete_recovery_code_for_user(request_claims.user_id, &mut *transaction).await;

    if let Err(e) = delete_current_recovery_code_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::RecoveryCodeDeletion.to_response());
    }

    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();
    let hashed_code = match argon2.hash_password(body.recovery_code.as_bytes(), &salt) {
        Ok(hash) => hash.to_string(),
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::RecoveryCodeHashCreation.to_response());
        }
    };

    let new_recovery_code = RecoveryCode {
        id: Uuid::new_v4(),
        user_id: request_claims.user_id,
        recovery_code: hashed_code,
        private_key_encrypted: body.private_key_encrypted.clone(),
        salt_used_to_derive_key_from_recovery_code: body
            .salt_used_to_derive_key_from_recovery_code
            .clone(),
    };

    let create_recovery_code_result =
        recovery_code::create_recovery_code(&new_recovery_code, &mut *transaction).await;

    if let Err(e) = create_recovery_code_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::RecoveryCodeCreation.to_response());
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Created().json(SaveRecoveryCodeResponse {
        code: "NEW_RECOVERY_CODE_SAVED".to_string(),
    })
}
