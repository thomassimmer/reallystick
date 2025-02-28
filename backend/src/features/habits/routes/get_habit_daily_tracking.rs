use crate::{
    core::constants::errors::AppError,
    features::{
        habits::{
            helpers::habit_daily_tracking,
            structs::responses::habit_daily_tracking::HabitDailyTrackingsResponse,
        },
        profile::structs::models::User,
    },
};
use actix_web::{get, web::Data, HttpResponse, Responder};
use sqlx::PgPool;

#[get("/")]
pub async fn get_habit_daily_tracking(pool: Data<PgPool>, request_user: User) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let get_habit_daily_tracking_result =
        habit_daily_tracking::get_habit_daily_tracking_for_user(&mut transaction, request_user.id)
            .await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match get_habit_daily_tracking_result {
        Ok(habit_daily_tracking) => HttpResponse::Ok().json(HabitDailyTrackingsResponse {
            code: "HABIT_DAILY_TRACKING_FETCHED".to_string(),
            habit_daily_tracking: habit_daily_tracking
                .iter()
                .map(|hdt| hdt.to_habit_daily_tracking_data())
                .collect(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
