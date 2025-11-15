// Get habit route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::habits::application::dto::requests::habit::GetHabitParams;
use crate::features::habits::application::dto::responses::habit::HabitResponse;
use crate::features::habits::application::use_cases::get_habit::GetHabitUseCase;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;
use actix_web::web::{Data, Path};
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/{habit_id}")]
pub async fn get_habit(pool: Data<PgPool>, params: Path<GetHabitParams>) -> impl Responder {
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
    let habit_repo = HabitRepositoryImpl::new(pool_clone);
    let get_habit_use_case = GetHabitUseCase::new(habit_repo);

    // Execute use case
    let result = get_habit_use_case
        .execute(params.habit_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(Some(habit)) => HttpResponse::Ok().json(HabitResponse {
            code: "HABIT_FETCHED".to_string(),
            habit: Some(habit.to_habit_data()),
        }),
        Ok(None) => HttpResponse::NotFound().json(AppError::HabitNotFound.to_response()),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
