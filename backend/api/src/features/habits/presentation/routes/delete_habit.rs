// Delete habit route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::habits::application::dto::requests::habit::GetHabitParams;
use crate::features::habits::application::dto::responses::habit::HabitResponse;
use crate::features::habits::application::use_cases::delete_habit::DeleteHabitUseCase;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;
use actix_web::web::{Data, Path, ReqData};
use actix_web::{delete, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[delete("/{habit_id}")]
pub async fn delete_habit(
    pool: Data<PgPool>,
    params: Path<GetHabitParams>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    if !request_claims.is_admin {
        return HttpResponse::Forbidden().body("Access denied");
    }

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
    let delete_habit_use_case = DeleteHabitUseCase::new(habit_repo);

    // Execute use case
    let result = delete_habit_use_case
        .execute(params.habit_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(HabitResponse {
            code: "HABIT_DELETED".to_string(),
            habit: None,
        }),
        Err(e) => {
            error!("Error: {}", e);
            // Check if it's a not found error
            if e.contains("not found") || e.contains("No rows affected") {
                HttpResponse::NotFound().json(AppError::HabitNotFound.to_response())
            } else {
                HttpResponse::InternalServerError().json(AppError::HabitDelete.to_response())
            }
        }
    }
}
