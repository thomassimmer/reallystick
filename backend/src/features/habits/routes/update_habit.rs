use crate::{
    core::constants::errors::AppError,
    features::habits::{
        helpers::{
            habit::{self, get_habit_by_id},
            habit_category::get_habit_category_by_id,
            unit::get_unit_by_id,
        },
        structs::{
            requests::habit::{HabitUpdateRequest, UpdateHabitParams},
            responses::habit::HabitResponse,
        },
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path},
    HttpResponse, Responder,
};
use serde_json::json;
use sqlx::PgPool;

#[put("/{habit_id}")]
pub async fn update_habit(
    pool: Data<PgPool>,
    params: Path<UpdateHabitParams>,
    body: Json<HabitUpdateRequest>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let get_habit_result = get_habit_by_id(&mut transaction, params.habit_id).await;

    let mut habit = match get_habit_result {
        Ok(r) => match r {
            Some(habit) => habit,
            None => return HttpResponse::NotFound().json(AppError::HabitNotFound.to_response()),
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    match get_habit_category_by_id(&mut transaction, body.category_id).await {
        Ok(r) => match r {
            Some(_) => {}
            None => {
                return HttpResponse::NotFound().json(AppError::HabitCategoryNotFound.to_response())
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    for unit in body.unit_ids.clone() {
        match get_unit_by_id(&mut transaction, unit).await {
            Ok(r) => {
                if r.is_none() {
                    return HttpResponse::NotFound().json(AppError::UnitNotFound.to_response());
                }
            }
            Err(e) => {
                eprintln!("Error: {}", e);
                return HttpResponse::InternalServerError()
                    .json(AppError::DatabaseQuery.to_response());
            }
        }
    }

    habit.short_name = json!(body.short_name).to_string();
    habit.long_name = json!(body.long_name).to_string();
    habit.description = json!(body.description).to_string();
    habit.reviewed = body.reviewed;
    habit.icon = body.icon.clone();
    habit.category_id = body.category_id;
    habit.unit_ids = json!(body.unit_ids.clone()).to_string();

    let update_habit_result = habit::update_habit(&mut transaction, &habit).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match update_habit_result {
        Ok(_) => HttpResponse::Ok().json(HabitResponse {
            code: "HABIT_UPDATED".to_string(),
            habit: Some(habit.to_habit_data()),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::HabitUpdate.to_response())
        }
    }
}
