use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        habits::{helpers::habit, structs::responses::habit::HabitsResponse},
    },
};
use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/")]
pub async fn get_habits(pool: Data<PgPool>, request_claims: ReqData<Claims>) -> impl Responder {
    let get_habits_result = if request_claims.is_admin {
        habit::get_habits(&**pool).await
    } else {
        habit::get_reviewed_and_personnal_habits(&**pool, request_claims.user_id).await
    };

    match get_habits_result {
        Ok(habits) => HttpResponse::Ok().json(HabitsResponse {
            code: "HABITS_FETCHED".to_string(),
            habits: habits.iter().map(|h| h.to_habit_data()).collect(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
