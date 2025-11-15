// Get profile information route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::profile::application::dto::responses::UserResponse;
use crate::features::profile::application::use_cases::get_profile::GetProfileUseCase;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, ReqData};
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/me")]
pub async fn get_profile_information(
    request_claims: ReqData<Claims>,
    pool: Data<PgPool>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repository and use case
    let pool_clone = pool.get_ref().clone();
    let user_repo = UserRepositoryImpl::new(pool_clone);
    let get_profile_use_case = GetProfileUseCase::new(user_repo);

    // Execute use case
    let result = get_profile_use_case
        .execute(request_claims.user_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(Some(user)) => HttpResponse::Ok().json(UserResponse {
            code: "PROFILE_FETCHED".to_string(),
            user: user.to_user_data(),
        }),
        Ok(None) => HttpResponse::NotFound().json(AppError::UserNotFound.to_response()),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response())
        }
    }
}
