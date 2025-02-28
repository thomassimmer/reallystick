use crate::{
    core::constants::errors::AppError,
    features::habits::{
        helpers::habit::get_habit_by_id,
        structs::{requests::habit::GetHabitParams, responses::habit::HabitResponse},
    },
};
use actix_web::{
    get,
    web::{Data, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/{habit_id}")]
pub async fn get_habit(pool: Data<PgPool>, params: Path<GetHabitParams>) -> impl Responder {
    let get_habit_result = get_habit_by_id(&**pool, params.habit_id).await;

    match get_habit_result {
        Ok(r) => match r {
            Some(habit) => HttpResponse::Ok().json(HabitResponse {
                code: "HABIT_FETCHED".to_string(),
                habit: Some(habit.to_habit_data()),
            }),
            None => HttpResponse::NotFound().json(AppError::HabitNotFound.to_response()),
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
