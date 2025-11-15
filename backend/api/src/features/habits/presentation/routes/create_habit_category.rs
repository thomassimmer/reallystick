// Create habit category route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::habits::application::dto::requests::habit_category::HabitCategoryCreateRequest;
use crate::features::habits::application::dto::responses::habit_category::HabitCategoryResponse;
use crate::features::habits::application::use_cases::create_habit_category::CreateHabitCategoryUseCase;
use crate::features::habits::domain::entities::habit_category::HabitCategory;
use crate::features::habits::infrastructure::repositories::habit_category_repository::HabitCategoryRepositoryImpl;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
use chrono::Utc;
use serde_json::json;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_habit_category(
    pool: Data<PgPool>,
    body: Json<HabitCategoryCreateRequest>,
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

    let (new_category_name, language_code) = match body.name.clone().into_iter().next() {
        Some(r) => r,
        None => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError()
                .json(AppError::HabitCategoryCreation.to_response());
        }
    };

    // Create repository and use case
    let pool_clone = pool.get_ref().clone();
    let category_repo = HabitCategoryRepositoryImpl::new(pool_clone);
    let create_category_use_case = CreateHabitCategoryUseCase::new(category_repo);

    // Create category entity
    let habit_category = HabitCategory {
        id: Uuid::new_v4(),
        name: json!(body.name).to_string(),
        icon: body.icon.clone(),
        created_at: Utc::now(),
    };

    // Execute use case
    let result = create_category_use_case
        .execute(
            &habit_category,
            language_code,
            new_category_name,
            &mut transaction,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(Some(existing)) => HttpResponse::Ok().json(HabitCategoryResponse {
            code: "HABIT_CATEGORY_ALREADY_EXISTING".to_string(),
            habit_category: Some(existing.to_habit_category_data()),
        }),
        Ok(None) => HttpResponse::Ok().json(HabitCategoryResponse {
            code: "HABIT_CATEGORY_CREATED".to_string(),
            habit_category: Some(habit_category.to_habit_category_data()),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
