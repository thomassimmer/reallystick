// Update habit daily tracking route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::habits::application::dto::requests::habit_daily_tracking::{
    HabitDailyTrackingUpdateRequest, UpdateHabitDailyTrackingParams,
};
use crate::features::habits::application::dto::responses::habit_daily_tracking::HabitDailyTrackingResponse;
use crate::features::habits::application::use_cases::update_habit_daily_tracking::UpdateHabitDailyTrackingUseCase;
use crate::features::habits::infrastructure::repositories::habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl;
use crate::features::habits::infrastructure::repositories::unit_repository::UnitRepositoryImpl;
use actix_web::web::{Data, Json, Path};
use actix_web::{put, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[put("/{habit_daily_tracking_id}")]
pub async fn update_habit_daily_tracking(
    pool: Data<PgPool>,
    params: Path<UpdateHabitDailyTrackingParams>,
    body: Json<HabitDailyTrackingUpdateRequest>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let tracking_repo = HabitDailyTrackingRepositoryImpl::new(pool_clone.clone());
    let unit_repo = UnitRepositoryImpl::new(pool_clone.clone());

    // Verify units exist
    match unit_repo
        .get_by_id_with_executor(body.unit_id, &mut *transaction)
        .await
    {
        Ok(Some(_)) => {}
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::UnitNotFound.to_response());
        }
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    }

    match unit_repo
        .get_by_id_with_executor(body.weight_unit_id, &mut *transaction)
        .await
    {
        Ok(Some(_)) => {}
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::UnitNotFound.to_response());
        }
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    }

    // Get existing tracking
    let mut tracking = match tracking_repo
        .get_by_id_with_executor(params.habit_daily_tracking_id, &mut *transaction)
        .await
    {
        Ok(Some(t)) => t,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound()
                .json(AppError::HabitDailyTrackingNotFound.to_response());
        }
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Update tracking fields
    tracking.datetime = body.datetime;
    tracking.quantity_per_set = body.quantity_per_set;
    tracking.quantity_of_set = body.quantity_of_set;
    tracking.unit_id = body.unit_id;
    tracking.weight = body.weight;
    tracking.weight_unit_id = body.weight_unit_id;

    // Execute use case
    let update_tracking_use_case = UpdateHabitDailyTrackingUseCase::new(tracking_repo);
    let result = update_tracking_use_case
        .execute(&tracking, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(HabitDailyTrackingResponse {
            code: "HABIT_DAILY_TRACKING_UPDATED".to_string(),
            habit_daily_tracking: Some(tracking.to_habit_daily_tracking_data()),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
