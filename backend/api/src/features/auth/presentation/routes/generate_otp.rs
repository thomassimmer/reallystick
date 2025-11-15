// Generate OTP route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::application::dto::responses::GenerateOtpResponse;
use crate::features::auth::application::use_cases::generate_otp::GenerateOtpUseCase;
use crate::features::auth::domain::entities::Claims;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, ReqData};
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/generate")]
pub async fn generate(pool: Data<PgPool>, request_claims: ReqData<Claims>) -> impl Responder {
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
    let generate_otp_use_case = GenerateOtpUseCase::new(user_repo);

    // Execute use case
    let result = generate_otp_use_case
        .execute(request_claims.user_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok((otp_base32, otp_auth_url)) => HttpResponse::Ok().json(GenerateOtpResponse {
            code: "OTP_GENERATED".to_string(),
            otp_base32,
            otp_auth_url,
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
