use crate::{
    core::constants::errors::AppError,
    features::{
        challenges::{
            helpers::{challenge::get_challenge_by_id, challenge_daily_tracking},
            structs::{
                models::challenge_daily_tracking::ChallengeDailyTracking,
                requests::challenge_daily_tracking::ChallengeDailyTrackingCreateRequest,
                responses::challenge_daily_tracking::ChallengeDailyTrackingResponse,
            },
        },
        habits::helpers::{habit::get_habit_by_id, unit::get_unit_by_id},
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
pub async fn create_challenge_daily_tracking(
    pool: Data<PgPool>,
    body: Json<ChallengeDailyTrackingCreateRequest>,
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

    match get_challenge_by_id(&mut transaction, body.challenge_id).await {
        Ok(r) => match r {
            Some(challenge) => {
                if !request_user.is_admin && challenge.creator != request_user.id {
                    return HttpResponse::Forbidden()
                        .json(AppError::InvalidChallengeCreator.to_response());
                }
            }
            None => {
                return HttpResponse::NotFound().json(AppError::ChallengeNotFound.to_response())
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    match get_habit_by_id(&mut transaction, body.habit_id).await {
        Ok(r) => {
            if r.is_none() {
                return HttpResponse::NotFound().json(AppError::HabitNotFound.to_response());
            }
        }
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

    let challenge_daily_tracking = ChallengeDailyTracking {
        id: Uuid::new_v4(),
        habit_id: body.habit_id,
        created_at: Utc::now(),
        challenge_id: body.challenge_id,
        day_of_program: body.day_of_program,
        quantity_per_set: body.quantity_per_set,
        quantity_of_set: body.quantity_of_set,
        unit_id: body.unit_id,
        weight: body.weight,
        weight_unit_id: body.weight_unit_id,
    };

    let create_challenge_daily_tracking_result =
        challenge_daily_tracking::create_challenge_daily_tracking(
            &mut transaction,
            &challenge_daily_tracking,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match create_challenge_daily_tracking_result {
        Ok(_) => HttpResponse::Ok().json(ChallengeDailyTrackingResponse {
            code: "CHALLENGE_DAILY_TRACKING_CREATED".to_string(),
            challenge_daily_tracking: Some(
                challenge_daily_tracking.to_challenge_daily_tracking_data(),
            ),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::ChallengeDailyTrackingCreation.to_response())
        }
    }
}
