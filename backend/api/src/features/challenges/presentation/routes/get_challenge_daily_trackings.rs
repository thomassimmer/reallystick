use crate::{
    core::constants::errors::AppError,
    features::challenges::{
        application::dto::{
            requests::challenge_daily_tracking::GetChallengeDailyTrackingsParams,
            responses::challenge_daily_tracking::ChallengeDailyTrackingsResponse,
        },
        domain::repositories::challenge_daily_tracking_repository::ChallengeDailyTrackingRepository,
        infrastructure::repositories::challenge_daily_tracking_repository::ChallengeDailyTrackingRepositoryImpl,
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
    let daily_tracking_repo = ChallengeDailyTrackingRepositoryImpl::new(pool.get_ref().clone());
    let get_challenge_daily_tracking_result = daily_tracking_repo
        .get_by_challenge_id(params.challenge_id)
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
