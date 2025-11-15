// Update habit participation route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::habits::application::dto::requests::habit_participation::{
    HabitParticipationUpdateRequest, UpdateHabitParticipationParams,
};
use crate::features::habits::application::dto::responses::habit_participation::HabitParticipationResponse;
use crate::features::habits::application::use_cases::update_habit_participation::UpdateHabitParticipationUseCase;
use crate::features::habits::infrastructure::repositories::habit_participation_repository::HabitParticipationRepositoryImpl;
use actix_web::web::{Data, Json, Path};
use actix_web::{put, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[put("/{habit_participation_id}")]
pub async fn update_habit_participation(
    pool: Data<PgPool>,
    params: Path<UpdateHabitParticipationParams>,
    body: Json<HabitParticipationUpdateRequest>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repository
    let pool_clone = pool.get_ref().clone();
    let participation_repo = HabitParticipationRepositoryImpl::new(pool_clone.clone());

    // Get existing participation
    let mut participation = match participation_repo
        .get_by_id_with_executor(params.habit_participation_id, &mut *transaction)
        .await
    {
        Ok(Some(p)) => p,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound()
                .json(AppError::HabitParticipationNotFound.to_response());
        }
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Update participation fields
    participation.color = body.color.clone();
    participation.to_gain = body.to_gain;
    participation.notifications_reminder_enabled = body.notifications_reminder_enabled;
    participation.reminder_time = body.reminder_time;
    participation.reminder_body = body.reminder_body.clone();

    // Execute use case
    let update_participation_use_case = UpdateHabitParticipationUseCase::new(participation_repo);
    let result = update_participation_use_case
        .execute(&participation, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(HabitParticipationResponse {
            code: "HABIT_PARTICIPATION_UPDATED".to_string(),
            habit_participation: Some(participation.to_habit_participation_data()),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
