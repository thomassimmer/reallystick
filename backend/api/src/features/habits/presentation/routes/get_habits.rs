// Get habits route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::habits::application::dto::responses::habit::HabitsResponse;
use crate::features::habits::application::use_cases::get_habits::GetHabitsUseCase;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;
use actix_web::web::{Data, ReqData};
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_habits(pool: Data<PgPool>, request_claims: ReqData<Claims>) -> impl Responder {
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
    let get_habits_use_case = GetHabitsUseCase::new(habit_repo);

    // Execute use case - use admin check for all habits vs user-specific
    let user_id = if request_claims.is_admin {
        None // Admin gets all habits
    } else {
        Some(request_claims.user_id) // Regular user gets reviewed and personal
    };

    let result = get_habits_use_case.execute(user_id, &mut transaction).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(habits) => HttpResponse::Ok().json(HabitsResponse {
            code: "HABITS_FETCHED".to_string(),
            habits: habits.iter().map(|h| h.to_habit_data()).collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
