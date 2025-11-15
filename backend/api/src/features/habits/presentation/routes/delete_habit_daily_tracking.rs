// Delete habit daily tracking route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::habits::application::dto::requests::habit_daily_tracking::GetHabitDailyTrackingParams;
use crate::features::habits::application::dto::responses::habit_daily_tracking::HabitDailyTrackingResponse;
use crate::features::habits::application::use_cases::delete_habit_daily_tracking::DeleteHabitDailyTrackingUseCase;
use crate::features::habits::infrastructure::repositories::habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl;
use actix_web::web::{Data, Path};
use actix_web::{delete, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[delete("/{habit_daily_tracking_id}")]
pub async fn delete_habit_daily_tracking(
    pool: Data<PgPool>,
    params: Path<GetHabitDailyTrackingParams>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repository and use case
    let pool_clone = pool.get_ref().clone();
    let tracking_repo = HabitDailyTrackingRepositoryImpl::new(pool_clone);
    let delete_tracking_use_case = DeleteHabitDailyTrackingUseCase::new(tracking_repo);

    // Execute use case
    let result = delete_tracking_use_case
        .execute(params.habit_daily_tracking_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(HabitDailyTrackingResponse {
            code: "HABIT_DAILY_TRACKING_DELETED".to_string(),
            habit_daily_tracking: None,
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
