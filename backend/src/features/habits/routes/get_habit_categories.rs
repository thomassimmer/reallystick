use crate::{
    core::constants::errors::AppError,
    features::habits::{
        helpers::habit_category, structs::responses::habit_category::HabitCategoriesResponse,
    },
};
use actix_web::{get, web::Data, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_habit_categories(pool: Data<PgPool>) -> impl Responder {
    let get_habit_categories_result = habit_category::get_habit_categories(&**pool).await;

    match get_habit_categories_result {
        Ok(habit_categories) => HttpResponse::Ok().json(HabitCategoriesResponse {
            code: "HABIT_CATEGORIES_FETCHED".to_string(),
            habit_categories: habit_categories
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
