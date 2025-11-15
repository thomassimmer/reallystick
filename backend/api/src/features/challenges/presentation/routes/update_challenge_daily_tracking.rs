use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{
            application::dto::{
                requests::challenge_daily_tracking::{
                    ChallengeDailyTrackingUpdateRequest, UpdateChallengeDailyTrackingParams,
                },
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
    put,
    web::{Data, Json, Path, ReqData},
    HttpResponse, Responder,
};
use chrono::Utc;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[put("/{challenge_daily_tracking_id}")]
pub async fn update_challenge_daily_tracking(
    pool: Data<PgPool>,
    params: Path<UpdateChallengeDailyTrackingParams>,
    body: Json<ChallengeDailyTrackingUpdateRequest>,
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

    let daily_tracking_repo = ChallengeDailyTrackingRepositoryImpl::new(pool.get_ref().clone());
    let challenge_repo = ChallengeRepositoryImpl::new(pool.get_ref().clone());

    let get_challenge_daily_tracking_result = daily_tracking_repo
        .get_by_id_with_executor(params.challenge_daily_tracking_id, &mut *transaction)
        .await;

    let mut challenge_daily_tracking = match get_challenge_daily_tracking_result {
        Ok(r) => match r {
            Some(challenge_daily_tracking) => challenge_daily_tracking,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::ChallengeDailyTrackingNotFound.to_response())
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    match challenge_repo
        .get_by_id_with_executor(challenge_daily_tracking.challenge_id, &mut *transaction)
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

    if let Some(note) = &body.note {
        if note.len() > CHALLENGE_DAILY_TRACKING_NOTE_MAX_LENGTH {
            return HttpResponse::BadRequest()
                .json(AppError::ChallengeDailyTrackingNoteTooLong.to_response());
        }
    }

    challenge_daily_tracking.habit_id = body.habit_id;
    challenge_daily_tracking.day_of_program = body.day_of_program;
    challenge_daily_tracking.quantity_per_set = body.quantity_per_set;
    challenge_daily_tracking.quantity_of_set = body.quantity_of_set;
    challenge_daily_tracking.unit_id = body.unit_id;
    challenge_daily_tracking.weight = body.weight;
    challenge_daily_tracking.weight_unit_id = body.weight_unit_id;
    challenge_daily_tracking.note = body.note.to_owned();
    challenge_daily_tracking.order_in_day = body.order_in_day;

    if let Err(e) = daily_tracking_repo
        .update_with_executor(&challenge_daily_tracking, &mut *transaction)
        .await
    {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::ChallengeDailyTrackingUpdate.to_response());
    }

    let mut challenge_daily_trackings = Vec::<ChallengeDailyTracking>::new();

    for day_of_program_to_repeat_on in body.days_to_repeat_on.clone() {
        challenge_daily_trackings.push(ChallengeDailyTracking {
            id: Uuid::new_v4(),
            habit_id: body.habit_id,
            created_at: Utc::now(),
            challenge_id: challenge_daily_tracking.challenge_id,
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

    if let Err(e) = daily_tracking_repo
        .create_batch_with_executor(&challenge_daily_trackings, &mut *transaction)
        .await
    {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::ChallengeDailyTrackingCreation.to_response());
    }

    challenge_daily_trackings.push(challenge_daily_tracking);

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(ChallengeDailyTrackingsResponse {
        code: "CHALLENGE_DAILY_TRACKING_UPDATED".to_string(),
        challenge_daily_trackings: challenge_daily_trackings
            .iter()
            .map(|cdt| cdt.to_challenge_daily_tracking_data())
            .collect(),
    })
}
