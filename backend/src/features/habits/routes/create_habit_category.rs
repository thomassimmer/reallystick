use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        habits::{
            helpers::habit_category::{self, get_habit_category_by_name},
            structs::{
                models::habit_category::HabitCategory,
                requests::habit_category::HabitCategoryCreateRequest,
                responses::habit_category::HabitCategoryResponse,
            },
        },
    },
};
use actix_web::{
    post,
    web::{Data, Json, ReqData},
    HttpResponse, Responder,
};
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
            return HttpResponse::InternalServerError()
                .json(AppError::HabitCategoryCreation.to_response())
        }
    };

    match get_habit_category_by_name(&mut *transaction, language_code, new_category_name).await {
        Ok(r) => {
            if let Some(habit_category) = r {
                return HttpResponse::Ok().json(HabitCategoryResponse {
                    code: "HABIT_CATEGORY_ALREADY_EXISTING".to_string(),
                    habit_category: Some(habit_category.to_habit_category_data()),
                });
            }
        }
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let habit_category = HabitCategory {
        id: Uuid::new_v4(),
        name: json!(body.name).to_string(),
        icon: body.icon.clone(),
        created_at: Utc::now(),
    };

    let create_habit_category_result =
        habit_category::create_habit_category(&mut *transaction, &habit_category).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match create_habit_category_result {
        Ok(_) => HttpResponse::Ok().json(HabitCategoryResponse {
            code: "HABIT_CATEGORY_CREATED".to_string(),
            habit_category: Some(habit_category.to_habit_category_data()),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::HabitCategoryCreation.to_response())
        }
    }
}
