// Update habit route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::habits::application::dto::requests::habit::{
    HabitUpdateRequest, UpdateHabitParams,
};
use crate::features::habits::application::dto::responses::habit::HabitResponse;
use crate::features::habits::application::use_cases::get_habit::GetHabitUseCase;
use crate::features::habits::application::use_cases::update_habit::UpdateHabitUseCase;
use crate::features::habits::domain::entities::habit::HABIT_DESCRIPTION_MAX_LENGTH;
use crate::features::habits::infrastructure::repositories::habit_category_repository::HabitCategoryRepositoryImpl;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;
use crate::features::habits::infrastructure::repositories::unit_repository::UnitRepositoryImpl;
use actix_web::web::{Data, Json, Path, ReqData};
use actix_web::{put, HttpResponse, Responder};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;

#[put("/{habit_id}")]
pub async fn update_habit(
    pool: Data<PgPool>,
    params: Path<UpdateHabitParams>,
    body: Json<HabitUpdateRequest>,
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
    let habit_repo = HabitRepositoryImpl::new(pool_clone.clone());
    let category_repo = HabitCategoryRepositoryImpl::new(pool_clone.clone());
    let unit_repo = UnitRepositoryImpl::new(pool_clone.clone());

    // Get existing habit - create a new repo instance for the get use case
    let habit_repo_for_get = HabitRepositoryImpl::new(pool_clone.clone());
    let get_habit_use_case = GetHabitUseCase::new(habit_repo_for_get);
    let mut habit = match get_habit_use_case
        .execute(params.habit_id, &mut transaction)
        .await
    {
        Ok(Some(h)) => h,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::HabitNotFound.to_response());
        }
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Validate category exists
    match category_repo
        .get_by_id_with_executor(body.category_id, &mut *transaction)
        .await
    {
        Ok(Some(_)) => {}
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
    }

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

    // Update habit fields
    habit.name = json!(body.name).to_string();
    habit.description = json!(body.description).to_string();
    habit.reviewed = body.reviewed;
    habit.icon = body.icon.clone();
    habit.category_id = body.category_id;
    habit.unit_ids = json!(body.unit_ids.clone()).to_string();

    // Execute update use case
    let update_habit_use_case = UpdateHabitUseCase::new(habit_repo);
    let result = update_habit_use_case
        .execute(&habit, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(HabitResponse {
            code: "HABIT_UPDATED".to_string(),
            habit: Some(habit.to_habit_data()),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::HabitUpdate.to_response())
        }
    }
}
