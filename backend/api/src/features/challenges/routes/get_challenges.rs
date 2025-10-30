use crate::{
    core::constants::errors::AppError,
    features::challenges::{helpers::challenge, structs::responses::challenge::ChallengesResponse},
};
use actix_web::{get, web::Data, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_challenges(pool: Data<PgPool>) -> impl Responder {
    let get_challenges_result = challenge::get_challenges(&**pool).await;

    match get_challenges_result {
        Ok(challenges) => HttpResponse::Ok().json(ChallengesResponse {
            code: "CHALLENGES_FETCHED".to_string(),
            challenges: challenges.iter().map(|h| h.to_challenge_data()).collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
