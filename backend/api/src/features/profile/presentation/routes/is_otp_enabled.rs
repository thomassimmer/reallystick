// Is OTP enabled route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::profile::application::dto::requests::IsOtpEnabledRequest;
use crate::features::profile::application::dto::responses::IsOtpEnabledResponse;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json};
use actix_web::{post, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[post("/is-otp-enabled")]
pub async fn is_otp_enabled(body: Json<IsOtpEnabledRequest>, pool: Data<PgPool>) -> impl Responder {
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
            // If user does not exist, say false to avoid scrapping usernames
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::Ok().json(IsOtpEnabledResponse {
                code: "OTP_STATUS".to_string(),
                otp_enabled: false,
            });
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

    HttpResponse::Ok().json(IsOtpEnabledResponse {
        code: "OTP_STATUS".to_string(),
        otp_enabled: user.otp_verified,
    })
}
