use crate::{
    core::constants::errors::AppError,
    features::challenges::{
        helpers::challenge_daily_tracking,
        structs::{
            requests::challenge_daily_tracking::GetChallengeDailyTrackingsParams,
            responses::challenge_daily_tracking::ChallengeDailyTrackingsResponse,
        },
    },
};
use actix_web::{
    get,
    web::{Data, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[get("/{challenge_id}")]
pub async fn get_challenge_daily_trackings(
    pool: Data<PgPool>,
    params: Path<GetChallengeDailyTrackingsParams>,
) -> impl Responder {
    let get_challenge_daily_tracking_result =
        challenge_daily_tracking::get_challenge_daily_trackings_for_challenge(
            &**pool,
            params.challenge_id,
        )
        .await;

    match get_challenge_daily_tracking_result {
        Ok(challenge_daily_tracking) => HttpResponse::Ok().json(ChallengeDailyTrackingsResponse {
            code: "CHALLENGE_DAILY_TRACKINGS_FETCHED".to_string(),
            challenge_daily_trackings: challenge_daily_tracking
                .iter()
                .map(|hdt| hdt.to_challenge_daily_tracking_data())
                .collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
