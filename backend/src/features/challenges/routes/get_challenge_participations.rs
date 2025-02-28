use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{
            helpers::challenge_participation,
            structs::responses::challenge_participation::ChallengeParticipationsResponse,
        },
    },
};
use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/")]
pub async fn get_challenge_participations(
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let get_challenges_result = challenge_participation::get_challenge_participations_for_user(
        &**pool,
        request_claims.user_id,
    )
    .await;

    match get_challenges_result {
        Ok(challenge_participations) => HttpResponse::Ok().json(ChallengeParticipationsResponse {
            code: "CHALLENGE_PARTICIPATIONS_FETCHED".to_string(),
            challenge_participations: challenge_participations
                .iter()
                .map(|hp| hp.to_challenge_participation_data())
                .collect(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
