// Create habit participation route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::habits::application::dto::requests::habit_participation::HabitParticipationCreateRequest;
use crate::features::habits::application::dto::responses::habit_participation::HabitParticipationResponse;
use crate::features::habits::application::use_cases::create_habit_participation::CreateHabitParticipationUseCase;
use crate::features::habits::domain::entities::habit_participation::HabitParticipation;
use crate::features::habits::infrastructure::repositories::habit_participation_repository::HabitParticipationRepositoryImpl;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
use chrono::Utc;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_habit_participation(
    pool: Data<PgPool>,
    body: Json<HabitParticipationCreateRequest>,
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

    // Create repositories and use case
    let pool_clone = pool.get_ref().clone();
    let participation_repo = HabitParticipationRepositoryImpl::new(pool_clone.clone());
    let habit_repo = HabitRepositoryImpl::new(pool_clone.clone());
    let create_participation_use_case =
        CreateHabitParticipationUseCase::new(participation_repo, habit_repo);

    // Create participation entity
    let participation = HabitParticipation {
        id: Uuid::new_v4(),
        user_id: request_claims.user_id,
        habit_id: body.habit_id,
        color: body.color.clone(),
        to_gain: body.to_gain,
        created_at: Utc::now(),
        notifications_reminder_enabled: false,
        reminder_time: None,
        reminder_body: None,
    };

    // Execute use case
    let result = create_participation_use_case
        .execute(&participation, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(HabitParticipationResponse {
            code: "HABIT_PARTICIPATION_CREATED".to_string(),
            habit_participation: Some(participation.to_habit_participation_data()),
        }),
        Err(AppError::HabitNotFound) => {
            HttpResponse::NotFound().json(AppError::HabitNotFound.to_response())
        }
        Err(AppError::HabitParticipationCreation) => {
            HttpResponse::BadRequest().json(AppError::HabitParticipationCreation.to_response())
        }
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
