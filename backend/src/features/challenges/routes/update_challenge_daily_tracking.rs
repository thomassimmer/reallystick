use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{
            helpers::{
                challenge::get_challenge_by_id,
                challenge_daily_tracking::{self, get_challenge_daily_tracking_by_id},
            },
            structs::{
                requests::challenge_daily_tracking::{
                    ChallengeDailyTrackingUpdateRequest, UpdateChallengeDailyTrackingParams,
                },
                responses::challenge_daily_tracking::ChallengeDailyTrackingResponse,
            },
        },
        habits::helpers::{habit::get_habit_by_id, unit::get_unit_by_id},
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

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

    let get_challenge_daily_tracking_result =
        get_challenge_daily_tracking_by_id(&mut *transaction, params.challenge_daily_tracking_id)
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

    match get_challenge_by_id(&mut *transaction, challenge_daily_tracking.challenge_id).await {
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

    match get_habit_by_id(&mut *transaction, body.habit_id).await {
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

    match get_unit_by_id(&mut *transaction, body.unit_id).await {
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

    match get_unit_by_id(&mut *transaction, body.weight_unit_id).await {
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
        if note.len() > 10000 {
            return HttpResponse::InternalServerError()
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

    let update_challenge_daily_tracking_result =
        challenge_daily_tracking::update_challenge_daily_tracking(
            &mut *transaction,
            &challenge_daily_tracking,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match update_challenge_daily_tracking_result {
        Ok(_) => HttpResponse::Ok().json(ChallengeDailyTrackingResponse {
            code: "CHALLENGE_DAILY_TRACKING_UPDATED".to_string(),
            challenge_daily_tracking: Some(
                challenge_daily_tracking.to_challenge_daily_tracking_data(),
            ),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::ChallengeDailyTrackingUpdate.to_response())
        }
    }
}
