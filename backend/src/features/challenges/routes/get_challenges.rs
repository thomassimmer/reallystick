use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{helpers::challenge, structs::responses::challenge::ChallengesResponse},
    },
};
use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/")]
pub async fn get_challenges(pool: Data<PgPool>, request_claims: ReqData<Claims>) -> impl Responder {
    let get_challenges_result = if request_claims.is_admin {
        challenge::get_challenges(&**pool).await
    } else {
        challenge::get_challenges(&**pool).await
        // challenge::get_created_and_joined_challenges(&**pool, request_claims.user_id).await
    };

    match get_challenges_result {
        Ok(challenges) => HttpResponse::Ok().json(ChallengesResponse {
            code: "CHALLENGES_FETCHED".to_string(),
            challenges: challenges.iter().map(|h| h.to_challenge_data()).collect(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
