use actix_web::{get, web::Data, HttpResponse, Responder};
use sqlx::PgPool;

use crate::{
    core::constants::errors::AppError,
    features::habits::{
        helpers::habit::fetch_habit_statistics,
        structs::{
            models::habit_statistics::HabitStatisticsCache,
            responses::habit::HabitStatisticsResponse,
        },
    },
};

#[get("/")]
pub async fn get_habit_statistics(
    pool: Data<PgPool>,
    cache: Data<HabitStatisticsCache>,
) -> impl Responder {
    if cache.needs_update().await {
        match fetch_habit_statistics(&pool).await {
            Ok(new_data) => {
                cache.update(new_data).await;
            }
            Err(err) => {
                eprintln!("Error: {}", err);
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
