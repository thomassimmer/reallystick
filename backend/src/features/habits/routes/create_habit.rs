use crate::{
    core::constants::errors::AppError,
    features::habits::{
        helpers::{habit, habit_category::get_habit_category_by_id},
        structs::{
            models::habit::Habit, requests::habit::HabitCreateRequest,
            responses::habit::HabitResponse,
        },
    },
};
use actix_web::{
    post,
    web::{Data, Json},
    HttpResponse, Responder,
};
use chrono::Utc;
use serde_json::json;
use sqlx::PgPool;
use uuid::Uuid;

#[post("/")]
pub async fn create_habit(pool: Data<PgPool>, body: Json<HabitCreateRequest>) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let category = match get_habit_category_by_id(&mut transaction, body.category_id).await {
        Ok(r) => match r {
            Some(category) => category,
            None => {
                return HttpResponse::NotFound().json(AppError::HabitCategoryNotFound.to_response())
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // TODO: check units exist

    let habit = Habit {
        id: Uuid::new_v4(),
        short_name: json!(body.short_name).to_string(),
        long_name: json!(body.long_name).to_string(),
        description: json!(body.description).to_string(),
        category_id: category.id,
        reviewed: false,
        icon: body.icon.clone(),
        created_at: Utc::now(),
        unit_ids: json!(body.unit_ids).to_string(),
    };

    let create_habit_result = habit::create_habit(&mut transaction, &habit).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match create_habit_result {
        Ok(_) => HttpResponse::Ok().json(HabitResponse {
            code: "HABIT_CREATED".to_string(),
            habit: Some(habit.to_habit_data()),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::HabitCreation.to_response())
        }
    }
}
