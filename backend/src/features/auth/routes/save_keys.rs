use actix_web::{
    post,
    web::{self, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::{
            models::Claims, requests::SaveKeysRequest, responses::SaveRecoveryCodeResponse,
        },
        profile::helpers::profile::{get_user_by_id, update_user_keys},
    },
};

#[post("/save-keys")]
pub async fn save_keys(
    body: web::Json<SaveKeysRequest>,
    pool: web::Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    // This view is for user without public / private keys yet.
    // It's only here for the migration towards to new system.

    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(_) => {
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response())
        }
    };

    let mut request_user = match get_user_by_id(&mut *transaction, request_claims.user_id).await {
        Ok(user) => match user {
            Some(user) => user,
            None => return HttpResponse::NotFound().json(AppError::UserNotFound.to_response()),
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response());
        }
    };

    if request_user.public_key.is_some() || request_user.private_key_encrypted.is_some() {
        return HttpResponse::Unauthorized().json(AppError::UserAlreadyHasKeys.to_response());
    }

    request_user.public_key = Some(body.public_key.clone());
    request_user.private_key_encrypted = Some(body.private_key_encrypted.clone());
    request_user.salt_used_to_derive_key_from_password =
        Some(body.salt_used_to_derive_key_from_password.clone());

    let save_keys_result = update_user_keys(&mut *transaction, &request_user).await;

    if let Err(e) = save_keys_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response());
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Created().json(SaveRecoveryCodeResponse {
        code: "NEW_KEYS_SAVED".to_string(),
    })
}
