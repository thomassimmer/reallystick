use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{
            application::dto::{
                requests::challenge_daily_tracking::ChallengeDailyTrackingCreateRequest,
                responses::challenge_daily_tracking::ChallengeDailyTrackingsResponse,
            },
            domain::entities::challenge_daily_tracking::{
                ChallengeDailyTracking, CHALLENGE_DAILY_TRACKING_NOTE_MAX_LENGTH,
            },
            infrastructure::repositories::{
                challenge_daily_tracking_repository::ChallengeDailyTrackingRepositoryImpl,
                challenge_repository::ChallengeRepositoryImpl,
            },
        },
        habits::infrastructure::repositories::{
            habit_repository::HabitRepositoryImpl, unit_repository::UnitRepositoryImpl,
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
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_challenge_daily_tracking(
    pool: Data<PgPool>,
    body: Json<ChallengeDailyTrackingCreateRequest>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    if let Some(note) = &body.note {
        if note.len() > CHALLENGE_DAILY_TRACKING_NOTE_MAX_LENGTH {
            return HttpResponse::BadRequest()
                .json(AppError::ChallengeDailyTrackingNoteTooLong.to_response());
        }
    }

    let challenge_repo = ChallengeRepositoryImpl::new(pool.get_ref().clone());
    match challenge_repo
        .get_by_id_with_executor(body.challenge_id, &mut *transaction)
        .await
    {
        Ok(r) => match r {
            Some(challenge) => {
                if !request_claims.is_admin && challenge.creator != request_claims.user_id {
                    return HttpResponse::Forbidden()
                        .json(AppError::InvalidChallengeCreator.to_response());
                }
            }
            None => {
                return HttpResponse::NotFound().json(AppError::ChallengeNotFound.to_response())
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let habit_repo = HabitRepositoryImpl::new(pool.get_ref().clone());
    let unit_repo = UnitRepositoryImpl::new(pool.get_ref().clone());

    match habit_repo
        .get_by_id_with_executor(body.habit_id, &mut *transaction)
        .await
    {
        Ok(r) => {
            if r.is_none() {
                return HttpResponse::NotFound().json(AppError::HabitNotFound.to_response());
            }
        }
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    match unit_repo
        .get_by_id_with_executor(body.unit_id, &mut *transaction)
        .await
    {
        Ok(r) => {
            if r.is_none() {
                return HttpResponse::NotFound().json(AppError::UnitNotFound.to_response());
            }
        }
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    }

    match unit_repo
        .get_by_id_with_executor(body.weight_unit_id, &mut *transaction)
        .await
    {
        Ok(r) => {
            if r.is_none() {
                return HttpResponse::NotFound().json(AppError::UnitNotFound.to_response());
            }
        }
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    }

    let mut challenge_daily_trackings = Vec::<ChallengeDailyTracking>::new();

    challenge_daily_trackings.push(ChallengeDailyTracking {
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
        note: body.note.to_owned(),
        order_in_day: body.order_in_day,
    });

    for day_of_program_to_repeat_on in body.days_to_repeat_on.clone() {
        challenge_daily_trackings.push(ChallengeDailyTracking {
            id: Uuid::new_v4(),
            habit_id: body.habit_id,
            created_at: Utc::now(),
            challenge_id: body.challenge_id,
            day_of_program: day_of_program_to_repeat_on,
            quantity_per_set: body.quantity_per_set,
            quantity_of_set: body.quantity_of_set,
            unit_id: body.unit_id,
            weight: body.weight,
            weight_unit_id: body.weight_unit_id,
            note: body.note.to_owned(),
            order_in_day: body.order_in_day,
        });
    }

    let daily_tracking_repo = ChallengeDailyTrackingRepositoryImpl::new(pool.get_ref().clone());
    let create_challenge_daily_tracking_result = daily_tracking_repo
        .create_batch_with_executor(&challenge_daily_trackings, &mut *transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match create_challenge_daily_tracking_result {
        Ok(_) => HttpResponse::Ok().json(ChallengeDailyTrackingsResponse {
            code: "CHALLENGE_DAILY_TRACKINGS_CREATED".to_string(),
            challenge_daily_trackings: challenge_daily_trackings
                .iter()
                .map(|cdt| cdt.to_challenge_daily_tracking_data())
                .collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::ChallengeDailyTrackingCreation.to_response())
        }
    }
}
