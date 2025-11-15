// Create habit route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::habits::application::dto::requests::habit::HabitCreateRequest;
use crate::features::habits::application::dto::responses::habit::HabitResponse;
use crate::features::habits::application::use_cases::create_habit::CreateHabitUseCase;
use crate::features::habits::domain::entities::habit::{Habit, HABIT_DESCRIPTION_MAX_LENGTH};
use crate::features::habits::infrastructure::repositories::habit_category_repository::HabitCategoryRepositoryImpl;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;
use crate::features::habits::infrastructure::repositories::unit_repository::UnitRepositoryImpl;
use actix_web::web::{Data, Json};
use actix_web::{post, HttpResponse, Responder};
use chrono::Utc;
use serde_json::json;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_habit(pool: Data<PgPool>, body: Json<HabitCreateRequest>) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let body = body.into_inner();

    // Validate description length
    if body
        .description
        .iter()
        .any(|(_language_code, description)| description.len() > HABIT_DESCRIPTION_MAX_LENGTH)
    {
        return HttpResponse::BadRequest().json(AppError::HabitDescriptionTooLong.to_response());
    }

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let category_repo = HabitCategoryRepositoryImpl::new(pool_clone.clone());
    let unit_repo = UnitRepositoryImpl::new(pool_clone.clone());
    let habit_repo = HabitRepositoryImpl::new(pool_clone.clone());

    // Validate category exists
    let category = match category_repo
        .get_by_id_with_executor(body.category_id, &mut *transaction)
        .await
    {
        Ok(Some(c)) => c,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::HabitCategoryNotFound.to_response());
        }
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Validate units exist
    for unit_id in body.unit_ids.clone() {
        match unit_repo
            .get_by_id_with_executor(unit_id, &mut *transaction)
            .await
        {
            Ok(Some(_)) => {}
            Ok(None) => {
                if let Err(e) = transaction.rollback().await {
                    error!("Error rolling back: {}", e);
                }
                return HttpResponse::NotFound().json(AppError::UnitNotFound.to_response());
            }
            Err(e) => {
                error!("Error: {}", e);
                if let Err(e) = transaction.rollback().await {
                    error!("Error rolling back: {}", e);
                }
                return HttpResponse::InternalServerError()
                    .json(AppError::DatabaseQuery.to_response());
            }
        }
    }

    // Create habit entity
    let habit = Habit {
        id: Uuid::new_v4(),
        name: json!(body.name).to_string(),
        description: json!(body.description).to_string(),
        category_id: category.id,
        reviewed: false,
        icon: body.icon.clone(),
        created_at: Utc::now(),
        unit_ids: json!(body.unit_ids).to_string(),
    };

    // Create use case and execute
    let create_habit_use_case = CreateHabitUseCase::new(habit_repo);
    let result = create_habit_use_case
        .execute(&habit, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(HabitResponse {
            code: "HABIT_CREATED".to_string(),
            habit: Some(habit.to_habit_data()),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::HabitCreation.to_response())
        }
    }
}
