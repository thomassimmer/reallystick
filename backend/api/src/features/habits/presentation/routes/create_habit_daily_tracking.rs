// Create habit daily tracking route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::habits::application::dto::requests::habit_daily_tracking::HabitDailyTrackingCreateRequest;
use crate::features::habits::application::dto::responses::habit_daily_tracking::HabitDailyTrackingResponse;
use crate::features::habits::application::use_cases::create_habit_daily_tracking::CreateHabitDailyTrackingUseCase;
use crate::features::habits::domain::entities::habit_daily_tracking::HabitDailyTracking;
use crate::features::habits::infrastructure::repositories::habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;
use crate::features::habits::infrastructure::repositories::unit_repository::UnitRepositoryImpl;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
use chrono::Utc;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_habit_daily_tracking(
    pool: Data<PgPool>,
    body: Json<HabitDailyTrackingCreateRequest>,
    request_claims: ReqData<Claims>,
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
    let habit_repo = HabitRepositoryImpl::new(pool_clone.clone());
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

    // Create use case
    let create_tracking_use_case = CreateHabitDailyTrackingUseCase::new(tracking_repo, habit_repo);

    // Create tracking entity
    let tracking = HabitDailyTracking {
        id: Uuid::new_v4(),
        user_id: request_claims.user_id,
        habit_id: body.habit_id,
        datetime: body.datetime,
        created_at: Utc::now(),
        quantity_per_set: body.quantity_per_set,
        quantity_of_set: body.quantity_of_set,
        unit_id: body.unit_id,
        weight: body.weight,
        weight_unit_id: body.weight_unit_id,
        challenge_daily_tracking: body.challenge_daily_tracking,
    };

    // Execute use case
    let result = create_tracking_use_case
        .execute(&tracking, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(HabitDailyTrackingResponse {
            code: "HABIT_DAILY_TRACKING_CREATED".to_string(),
            habit_daily_tracking: Some(tracking.to_habit_daily_tracking_data()),
        }),
        Err(AppError::HabitNotFound) => {
            HttpResponse::NotFound().json(AppError::HabitNotFound.to_response())
        }
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
