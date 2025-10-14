use actix_web::{get, web::Data, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

use crate::{
    core::constants::errors::AppError,
    features::challenges::{
        helpers::challenge::fetch_challenge_statistics,
        structs::{
            models::challenge_statistics::ChallengeStatisticsCache,
            responses::challenge::ChallengeStatisticsResponse,
        },
    },
};

#[get("/")]
pub async fn get_challenge_statistics(
    pool: Data<PgPool>,
    cache: Data<ChallengeStatisticsCache>,
) -> impl Responder {
    if cache.needs_update().await {
        match fetch_challenge_statistics(&pool).await {
            Ok(new_data) => {
                cache.update(new_data).await;
            }
            Err(err) => {
                error!("Error: {}", err);
                return HttpResponse::InternalServerError()
                    .json(AppError::DatabaseTransaction.to_response());
            }
        }
    }

    let statistics = cache.get_data().await;
    HttpResponse::Ok().json(ChallengeStatisticsResponse {
        code: "CHALLENGE_STATISTICS_FETCHED".to_string(),
        statistics,
    })
}
