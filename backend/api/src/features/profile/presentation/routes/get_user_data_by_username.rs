// Get user data by username route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::profile::application::dto::requests::GetUserPublicDataByUsernameRequest;
use crate::features::profile::application::dto::responses::UserPublicResponse;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json};
use actix_web::{post, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[post("/by-username/")]
pub async fn get_user_data_by_username(
    body: Json<GetUserPublicDataByUsernameRequest>,
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

    // Create repository
    let pool_clone = pool.get_ref().clone();
    let user_repo = UserRepositoryImpl::new(pool_clone);

    // Get user by username
    let username_lower = body.username.to_lowercase();
    let user = match user_repo
        .get_by_username_with_executor(&username_lower, &mut *transaction)
        .await
    {
        Ok(Some(u)) => u,
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
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(UserPublicResponse {
        code: "USER_PUBLIC_DATA_FETCHED".to_string(),
        user: user.to_user_public_data(),
    })
}
