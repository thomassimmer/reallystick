use crate::{
    core::constants::errors::AppError,
    features::profile::{
        helpers::profile::get_user_by_username,
        structs::{requests::IsOtpEnabledRequest, responses::IsOtpEnabledResponse},
    },
};
use actix_web::{post, web, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[post("/is-otp-enabled")]
pub async fn is_otp_enabled(
    body: web::Json<IsOtpEnabledRequest>,
    pool: web::Data<PgPool>,
) -> impl Responder {
    // Check if user already exists
    let existing_user = get_user_by_username(&**pool, &body.username).await;

    match existing_user {
        Ok(existing_user) => match existing_user {
            Some(existing_user) => HttpResponse::Ok().json(IsOtpEnabledResponse {
                code: "OTP_STATUS".to_string(),
                otp_enabled: existing_user.otp_verified,
            }),
            // If user does not exist, say false to avoid scrapping usernames
            None => HttpResponse::Ok().json(IsOtpEnabledResponse {
                code: "OTP_STATUS".to_string(),
                otp_enabled: false,
            }),
        },
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
