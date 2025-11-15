use actix_web::{get, web::Data, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

use crate::{
    core::constants::errors::AppError,
    features::challenges::{
        application::dto::responses::challenge::ChallengeStatisticsResponse,
        application::use_cases::get_challenge_statistics::GetChallengeStatisticsUseCase,
        domain::entities::challenge_statistics::ChallengeStatisticsCache,
        infrastructure::services::challenge_statistics_service::ChallengeStatisticsService,
    },
};

#[get("/")]
pub async fn get_challenge_statistics(
    pool: Data<PgPool>,
    cache: Data<ChallengeStatisticsCache>,
) -> impl Responder {
    if cache.needs_update().await {
        let statistics_service = ChallengeStatisticsService::new(pool.get_ref().clone());
        let use_case = GetChallengeStatisticsUseCase::new(statistics_service);

        match use_case.execute().await {
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
