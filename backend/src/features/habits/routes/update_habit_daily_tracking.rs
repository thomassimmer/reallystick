use crate::{
    core::constants::errors::AppError,
    features::habits::{
        helpers::{
            habit_daily_tracking::{self, get_habit_daily_tracking_by_id},
            unit::get_unit_by_id,
        },
        structs::{
            requests::habit_daily_tracking::{
                HabitDailyTrackingUpdateRequest, UpdateHabitDailyTrackingParams,
            },
            responses::habit_daily_tracking::HabitDailyTrackingResponse,
        },
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[put("/{habit_daily_tracking_id}")]
pub async fn update_habit_daily_tracking(
    pool: Data<PgPool>,
    params: Path<UpdateHabitDailyTrackingParams>,
    body: Json<HabitDailyTrackingUpdateRequest>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let get_habit_daily_tracking_result =
        get_habit_daily_tracking_by_id(&mut transaction, params.habit_daily_tracking_id).await;

    let mut habit_daily_tracking = match get_habit_daily_tracking_result {
        Ok(r) => match r {
            Some(habit_daily_tracking) => habit_daily_tracking,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::HabitDailyTrackingNotFound.to_response())
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    match get_unit_by_id(&mut transaction, body.unit_id).await {
        Ok(r) => {
            if r.is_none() {
                return HttpResponse::NotFound().json(AppError::UnitNotFound.to_response());
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    }

    match get_unit_by_id(&mut transaction, body.weight_unit_id).await {
        Ok(r) => {
            if r.is_none() {
                return HttpResponse::NotFound().json(AppError::UnitNotFound.to_response());
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    }

    habit_daily_tracking.datetime = body.datetime;
    habit_daily_tracking.quantity_per_set = body.quantity_per_set;
    habit_daily_tracking.quantity_of_set = body.quantity_of_set;
    habit_daily_tracking.unit_id = body.unit_id;
    habit_daily_tracking.weight = body.weight;
    habit_daily_tracking.weight_unit_id = body.weight_unit_id;

    let update_habit_daily_tracking_result =
        habit_daily_tracking::update_habit_daily_tracking(&mut transaction, &habit_daily_tracking)
            .await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match update_habit_daily_tracking_result {
        Ok(_) => HttpResponse::Ok().json(HabitDailyTrackingResponse {
            code: "HABIT_DAILY_TRACKING_UPDATED".to_string(),
            habit_daily_tracking: Some(habit_daily_tracking.to_habit_daily_tracking_data()),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::HabitDailyTrackingUpdate.to_response())
        }
    }
}
