// Update password route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::core::structs::responses::GenericResponse;
use crate::features::auth::domain::entities::Claims;
use crate::features::profile::application::dto::requests::UpdateUserPasswordRequest;
use crate::features::profile::application::dto::responses::UserResponse;
use crate::features::profile::application::use_cases::get_profile::GetProfileUseCase;
use crate::features::profile::application::use_cases::update_password::UpdatePasswordUseCase;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[post("/update-password")]
pub async fn update_password(
    body: Json<UpdateUserPasswordRequest>,
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
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
    let user_repo_for_get = UserRepositoryImpl::new(pool_clone.clone());

    // Get user
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

    // Execute update password use case
    let update_password_use_case = UpdatePasswordUseCase::new(user_repo);
    let result = update_password_use_case
        .execute(
            &mut request_user,
            body.current_password.clone(),
            body.new_password.clone(),
            &mut transaction,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(UserResponse {
            code: "PASSWORD_CHANGED".to_string(),
            user: request_user.to_user_data(),
        }),
        Err(AppError::InvalidUsernameOrPassword) => {
            HttpResponse::Unauthorized().json(AppError::InvalidUsernameOrPassword.to_response())
        }
        Err(AppError::PasswordTooShort) => HttpResponse::Unauthorized().json(GenericResponse {
            code: "PASSWORD_TOO_SHORT".to_string(),
            message: "This password is too short.".to_string(),
        }),
        Err(AppError::PasswordTooWeak) => HttpResponse::Unauthorized().json(GenericResponse {
            code: "PASSWORD_TOO_WEAK".to_string(),
            message: "This password is too weak.".to_string(),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
