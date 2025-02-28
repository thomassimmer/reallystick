use crate::{
    core::constants::errors::AppError,
    features::{
        habits::{
            helpers::{habit::get_habit_by_id, habit_daily_tracking},
            structs::{
                models::habit_daily_tracking::HabitDailyTracking,
                requests::habit_daily_tracking::HabitDailyTrackingCreateRequest,
                responses::habit_daily_tracking::HabitDailyTrackingResponse,
            },
        },
        profile::structs::models::User,
    },
};
use actix_web::{
    post,
    web::{Data, Json},
    HttpResponse, Responder,
};
use chrono::Utc;
use sqlx::PgPool;
use uuid::Uuid;

#[post("/")]
pub async fn create_habit_daily_tracking(
    pool: Data<PgPool>,
    body: Json<HabitDailyTrackingCreateRequest>,
    request_user: User,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    match get_habit_by_id(&mut transaction, body.habit_id).await {
        Ok(r) => match r {
            Some(_) => {}
            None => return HttpResponse::NotFound().json(AppError::HabitNotFound.to_response()),
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let habit_daily_tracking = HabitDailyTracking {
        id: Uuid::new_v4(),
        user_id: request_user.id,
        created_at: Utc::now(),
        habit_id: body.habit_id,
        day: body.day,
        duration: body.duration,
        quantity_per_set: body.quantity_per_set,
        quantity_of_set: body.quantity_of_set,
        unit: body.unit.clone(),
        reset: body.reset,
    };

    let create_habit_daily_tracking_result =
        habit_daily_tracking::create_habit_daily_tracking(&mut transaction, &habit_daily_tracking)
            .await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match create_habit_daily_tracking_result {
        Ok(_) => HttpResponse::Ok().json(HabitDailyTrackingResponse {
            code: "HABIT_DAILY_TRACKING_CREATED".to_string(),
            habit_daily_tracking: Some(habit_daily_tracking.to_habit_daily_tracking_data()),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::HabitDailyTrackingCreation.to_response())
        }
    }
}
