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

#[get("/{challenge_id}")]
pub async fn get_challenge_daily_trackings(
    pool: Data<PgPool>,
    params: Path<GetChallengeDailyTrackingsParams>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let get_challenge_daily_tracking_result =
        challenge_daily_tracking::get_challenge_daily_trackings_for_challenge(
            &mut transaction,
            params.challenge_id,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match get_challenge_daily_tracking_result {
        Ok(challenge_daily_tracking) => HttpResponse::Ok().json(ChallengeDailyTrackingsResponse {
            code: "CHALLENGE_DAILY_TRACKINGS_FETCHED".to_string(),
            challenge_daily_trackings: challenge_daily_tracking
                .iter()
                .map(|hdt| hdt.to_challenge_daily_tracking_data())
                .collect(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
