// Get habit categories route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::habits::application::dto::responses::habit_category::HabitCategoriesResponse;
use crate::features::habits::application::use_cases::get_habit_categories::GetHabitCategoriesUseCase;
use crate::features::habits::infrastructure::repositories::habit_category_repository::HabitCategoryRepositoryImpl;
use actix_web::web::Data;
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_habit_categories(pool: Data<PgPool>) -> impl Responder {
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
    let category_repo = HabitCategoryRepositoryImpl::new(pool_clone);
    let get_categories_use_case = GetHabitCategoriesUseCase::new(category_repo);

    // Execute use case
    let result = get_categories_use_case.execute(&mut transaction).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(categories) => HttpResponse::Ok().json(HabitCategoriesResponse {
            code: "HABIT_CATEGORIES_FETCHED".to_string(),
            habit_categories: categories
                .iter()
                .map(|hc| hc.to_habit_category_data())
                .collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
