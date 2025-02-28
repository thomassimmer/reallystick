use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        habits::{
            helpers::{habit::get_habit_by_id, habit_participation},
            structs::{
                models::habit_participation::HabitParticipation,
                requests::habit_participation::HabitParticipationCreateRequest,
                responses::habit_participation::HabitParticipationResponse,
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
use sqlx::PgPool;
use uuid::Uuid;

#[post("/")]
pub async fn create_habit_participation(
    pool: Data<PgPool>,
    body: Json<HabitParticipationCreateRequest>,
    request_claims: ReqData<Claims>,
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

    let habit_participation = HabitParticipation {
        id: Uuid::new_v4(),
        user_id: request_claims.user_id,
        habit_id: body.habit_id,
        color: body.color.clone(),
        to_gain: body.to_gain,
        created_at: Utc::now(),
        notifications_reminder_enabled: false,
        reminder_time: None,
        timezone: None,
    };

    let create_habit_participation_result =
        habit_participation::create_habit_participation(&mut transaction, &habit_participation)
            .await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match create_habit_participation_result {
        Ok(_) => HttpResponse::Ok().json(HabitParticipationResponse {
            code: "HABIT_PARTICIPATION_CREATED".to_string(),
            habit_participation: Some(habit_participation.to_habit_participation_data()),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::HabitParticipationCreation.to_response())
        }
    }
}
