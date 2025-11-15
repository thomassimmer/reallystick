use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{
            application::dto::responses::challenge_participation::ChallengeParticipationsResponse,
            domain::repositories::challenge_participation_repository::ChallengeParticipationRepository,
            infrastructure::repositories::challenge_participation_repository::ChallengeParticipationRepositoryImpl,
        },
    },
};
use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_challenge_participations(
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let participation_repo = ChallengeParticipationRepositoryImpl::new(pool.get_ref().clone());
    let get_challenges_result = participation_repo
        .get_by_user_id(request_claims.user_id)
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
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
