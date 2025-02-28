use crate::{
    core::constants::errors::AppError,
    features::habits::{
        helpers::habit_participation::{self, get_habit_participation_by_id},
        structs::{
            requests::habit_participation::{
                HabitParticipationUpdateRequest, UpdateHabitParticipationParams,
            },
            responses::habit_participation::HabitParticipationResponse,
        },
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[put("/{habit_participation_id}")]
pub async fn update_habit_participation(
    pool: Data<PgPool>,
    params: Path<UpdateHabitParticipationParams>,
    body: Json<HabitParticipationUpdateRequest>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let get_habit_participation_result =
        get_habit_participation_by_id(&mut transaction, params.habit_participation_id).await;

    let mut habit_participation = match get_habit_participation_result {
        Ok(r) => match r {
            Some(habit_participation) => habit_participation,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::HabitParticipationNotFound.to_response())
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    habit_participation.color = body.color.clone();
    habit_participation.to_gain = body.to_gain;
    habit_participation.notifications_reminder_enabled = body.notifications_reminder_enabled;
    habit_participation.reminder_time = body.reminder_time;
    habit_participation.timezone = body.timezone.clone();

    let update_habit_participation_result =
        habit_participation::update_habit_participation(&mut transaction, &habit_participation)
            .await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match update_habit_participation_result {
        Ok(_) => HttpResponse::Ok().json(HabitParticipationResponse {
            code: "HABIT_PARTICIPATION_UPDATED".to_string(),
            habit_participation: Some(habit_participation.to_habit_participation_data()),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::HabitParticipationUpdate.to_response())
        }
    }
}
