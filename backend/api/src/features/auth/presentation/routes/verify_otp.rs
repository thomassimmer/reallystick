// Verify OTP route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::application::dto::requests::VerifyOtpRequest;
use crate::features::auth::application::dto::responses::VerifyOtpResponse;
use crate::features::auth::application::use_cases::verify_otp::VerifyOtpUseCase;
use crate::features::auth::domain::entities::Claims;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[post("/verify")]
pub async fn verify(
    body: Json<VerifyOtpRequest>,
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

    // Create repository and use case
    let pool_clone = pool.get_ref().clone();
    let user_repo = UserRepositoryImpl::new(pool_clone);
    let verify_otp_use_case = VerifyOtpUseCase::new(user_repo);

    // Execute use case
    let result = verify_otp_use_case
        .execute(request_claims.user_id, body.code.clone(), &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(VerifyOtpResponse {
            code: "OTP_VERIFIED".to_string(),
            otp_verified: true,
        }),
        Err(AppError::InvalidOneTimePassword) => {
            HttpResponse::Unauthorized().json(AppError::InvalidOneTimePassword.to_response())
        }
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
