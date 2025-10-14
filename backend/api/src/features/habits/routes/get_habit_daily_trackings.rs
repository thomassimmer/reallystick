use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        habits::{
            helpers::habit_daily_tracking,
            structs::responses::habit_daily_tracking::HabitDailyTrackingsResponse,
        },
    },
};
use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_habit_daily_trackings(
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let get_habit_daily_tracking_result =
        habit_daily_tracking::get_habit_daily_trackings_for_user(&**pool, request_claims.user_id)
            .await;

    match get_habit_daily_tracking_result {
        Ok(habit_daily_tracking) => HttpResponse::Ok().json(HabitDailyTrackingsResponse {
            code: "HABIT_DAILY_TRACKING_FETCHED".to_string(),
            habit_daily_trackings: habit_daily_tracking
                .iter()
                .map(|hdt| hdt.to_habit_daily_tracking_data())
                .collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
