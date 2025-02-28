use crate::{
    core::constants::errors::AppError,
    features::habits::{
        helpers::habit_daily_tracking::delete_habit_daily_tracking_by_id,
        structs::{
            requests::habit_daily_tracking::GetHabitDailyTrackingParams,
            responses::habit_daily_tracking::HabitDailyTrackingResponse,
        },
    },
};
use actix_web::{
    delete,
    web::{Data, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[delete("/{habit_daily_tracking_id}")]
pub async fn delete_habit_daily_tracking(
    pool: Data<PgPool>,
    params: Path<GetHabitDailyTrackingParams>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let delete_habit_result =
        delete_habit_daily_tracking_by_id(&mut *transaction, params.habit_daily_tracking_id).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match delete_habit_result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                HttpResponse::Ok().json(HabitDailyTrackingResponse {
                    code: "HABIT_DAILY_TRACKING_DELETED".to_string(),
                    habit_daily_tracking: None,
                })
            } else {
                HttpResponse::NotFound().json(AppError::HabitDailyTrackingNotFound.to_response())
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::HabitDailyTrackingDelete.to_response())
        }
    }
}
