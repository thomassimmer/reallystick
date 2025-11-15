use actix_web::{get, web::Data, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

use crate::{
    core::constants::errors::AppError,
    features::habits::{
        application::dto::responses::habit::HabitStatisticsResponse,
        application::use_cases::get_habit_statistics::GetHabitStatisticsUseCase,
        domain::entities::habit_statistics::HabitStatisticsCache,
        infrastructure::services::habit_statistics_service::HabitStatisticsService,
    },
};

#[get("/")]
pub async fn get_habit_statistics(
    pool: Data<PgPool>,
    cache: Data<HabitStatisticsCache>,
) -> impl Responder {
    if cache.needs_update().await {
        let statistics_service = HabitStatisticsService::new(pool.get_ref().clone());
        let use_case = GetHabitStatisticsUseCase::new(statistics_service);

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
    HttpResponse::Ok().json(HabitStatisticsResponse {
        code: "HABIT_STATISTICS_FETCHED".to_string(),
        statistics,
    })
}
