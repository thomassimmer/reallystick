// Save keys route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::application::dto::requests::SaveKeysRequest;
use crate::features::auth::application::dto::responses::SaveRecoveryCodeResponse;
use crate::features::auth::application::use_cases::save_keys::SaveKeysUseCase;
use crate::features::auth::domain::entities::Claims;
use crate::features::profile::application::use_cases::get_profile::GetProfileUseCase;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[post("/save-keys")]
pub async fn save_keys(
    body: Json<SaveKeysRequest>,
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    // This view is for user without public / private keys yet.
    // It's only here for the migration towards to new system.

    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let user_repo = UserRepositoryImpl::new(pool_clone.clone());

    // Get existing user
    let user_repo_for_get = UserRepositoryImpl::new(pool_clone.clone());
    let get_profile_use_case = GetProfileUseCase::new(user_repo_for_get);
    let mut request_user = match get_profile_use_case
        .execute(request_claims.user_id, &mut transaction)
        .await
    {
        Ok(Some(user)) => user,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::UserNotFound.to_response());
        }
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response());
        }
    };

    // Check if user already has keys
    if request_user.public_key.is_some() || request_user.private_key_encrypted.is_some() {
        if let Err(e) = transaction.rollback().await {
            error!("Error rolling back: {}", e);
        }
        return HttpResponse::Unauthorized().json(AppError::UserAlreadyHasKeys.to_response());
    }

    // Update user with keys
    request_user.public_key = Some(body.public_key.clone());
    request_user.private_key_encrypted = Some(body.private_key_encrypted.clone());
    request_user.salt_used_to_derive_key_from_password =
        Some(body.salt_used_to_derive_key_from_password.clone());

    // Execute save keys use case
    let save_keys_use_case = SaveKeysUseCase::new(user_repo);
    let result = save_keys_use_case
        .execute(&request_user, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Created().json(SaveRecoveryCodeResponse {
            code: "NEW_KEYS_SAVED".to_string(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response())
        }
    }
}
