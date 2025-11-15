// Delete habit participation route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::habits::application::dto::requests::habit_participation::GetHabitParticipationParams;
use crate::features::habits::application::dto::responses::habit_participation::HabitParticipationResponse;
use crate::features::habits::application::use_cases::delete_habit_participation::DeleteHabitParticipationUseCase;
use crate::features::habits::infrastructure::repositories::habit_participation_repository::HabitParticipationRepositoryImpl;
use actix_web::web::{Data, Path};
use actix_web::{delete, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[delete("/{habit_participation_id}")]
pub async fn delete_habit_participation(
    pool: Data<PgPool>,
    params: Path<GetHabitParticipationParams>,
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
    let participation_repo = HabitParticipationRepositoryImpl::new(pool_clone);
    let delete_participation_use_case = DeleteHabitParticipationUseCase::new(participation_repo);

    // Execute use case
    let result = delete_participation_use_case
        .execute(params.habit_participation_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(HabitParticipationResponse {
            code: "HABIT_PARTICIPATION_DELETED".to_string(),
            habit_participation: None,
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
