// Update habit category route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::habits::application::dto::requests::habit_category::{
    HabitCategoryUpdateRequest, UpdateHabitCategoryParams,
};
use crate::features::habits::application::dto::responses::habit_category::HabitCategoryResponse;
use crate::features::habits::application::use_cases::update_habit_category::UpdateHabitCategoryUseCase;
use crate::features::habits::infrastructure::repositories::habit_category_repository::HabitCategoryRepositoryImpl;
use actix_web::web::{Data, Json, Path, ReqData};
use actix_web::{put, HttpResponse, Responder};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;

#[put("/{habit_category_id}")]
pub async fn update_habit_category(
    pool: Data<PgPool>,
    params: Path<UpdateHabitCategoryParams>,
    body: Json<HabitCategoryUpdateRequest>,
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

    // Create repository
    let pool_clone = pool.get_ref().clone();
    let category_repo = HabitCategoryRepositoryImpl::new(pool_clone.clone());

    // Get existing category
    let mut habit_category = match category_repo
        .get_by_id_with_executor(params.habit_category_id, &mut *transaction)
        .await
    {
        Ok(Some(c)) => c,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::HabitNotFound.to_response());
        }
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Update category fields
    habit_category.name = json!(body.name).to_string();
    habit_category.icon = body.icon.clone();

    // Execute use case
    let update_category_use_case = UpdateHabitCategoryUseCase::new(category_repo);
    let result = update_category_use_case
        .execute(&habit_category, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(HabitCategoryResponse {
            code: "HABIT_CATEGORY_UPDATED".to_string(),
            habit_category: Some(habit_category.to_habit_category_data()),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
