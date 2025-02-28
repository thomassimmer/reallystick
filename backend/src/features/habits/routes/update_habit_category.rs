use crate::{
    core::constants::errors::AppError,
    features::{
        habits::{
            helpers::habit_category::{self, get_habit_category_by_id},
            structs::{
                requests::habit_category::{HabitCategoryUpdateRequest, UpdateHabitCategoryParams},
                responses::habit_category::HabitCategoryResponse,
            },
        },
        profile::structs::models::User,
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path},
    HttpResponse, Responder,
};
use serde_json::json;
use sqlx::PgPool;

#[put("/{habit_category_id}")]
pub async fn update_habit_category(
    pool: Data<PgPool>,
    params: Path<UpdateHabitCategoryParams>,
    body: Json<HabitCategoryUpdateRequest>,
    request_user: User,
) -> impl Responder {
    if !request_user.is_admin {
        return HttpResponse::Forbidden().body("Access denied");
    }

    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let get_habit_category_result =
        get_habit_category_by_id(&mut transaction, params.habit_category_id).await;

    let mut habit_category = match get_habit_category_result {
        Ok(r) => match r {
            Some(habit) => habit,
            None => return HttpResponse::NotFound().json(AppError::HabitNotFound.to_response()),
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    habit_category.name = json!(body.name).to_string();
    habit_category.icon = body.icon.clone();

    let update_habit_category_result =
        habit_category::update_habit_category(&mut transaction, &habit_category).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match update_habit_category_result {
        Ok(_) => HttpResponse::Ok().json(HabitCategoryResponse {
            code: "HABIT_CATEGORY_UPDATED".to_string(),
            habit_category: Some(habit_category.to_habit_category_data()),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::HabitUpdate.to_response())
        }
    }
}
