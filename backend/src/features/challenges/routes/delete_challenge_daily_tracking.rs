use crate::{
    core::constants::errors::AppError,
    features::{
        challenges::{
            helpers::{
                challenge::get_challenge_by_id,
                challenge_daily_tracking::{
                    delete_challenge_daily_tracking_by_id, get_challenge_daily_tracking_by_id,
                },
            },
            structs::{
                requests::challenge_daily_tracking::GetChallengeDailyTrackingParams,
                responses::challenge_daily_tracking::ChallengeDailyTrackingResponse,
            },
        },
        profile::structs::models::User,
    },
};
use actix_web::{
    delete,
    web::{Data, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[delete("/{challenge_daily_tracking_id}")]
pub async fn delete_challenge_daily_tracking(
    pool: Data<PgPool>,
    params: Path<GetChallengeDailyTrackingParams>,
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

    let get_challenge_daily_tracking_result =
        get_challenge_daily_tracking_by_id(&mut transaction, params.challenge_daily_tracking_id)
            .await;

    let challenge_daily_tracking = match get_challenge_daily_tracking_result {
        Ok(r) => match r {
            Some(challenge_daily_tracking) => challenge_daily_tracking,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::ChallengeDailyTrackingNotFound.to_response())
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    match get_challenge_by_id(&mut transaction, challenge_daily_tracking.challenge_id).await {
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

    let delete_challenge_result =
        delete_challenge_daily_tracking_by_id(&mut transaction, params.challenge_daily_tracking_id)
            .await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match delete_challenge_result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                HttpResponse::Ok().json(ChallengeDailyTrackingResponse {
                    code: "CHALLENGE_DAILY_TRACKING_DELETED".to_string(),
                    challenge_daily_tracking: None,
                })
            } else {
                HttpResponse::NotFound()
                    .json(AppError::ChallengeDailyTrackingNotFound.to_response())
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::ChallengeDailyTrackingDelete.to_response())
        }
    }
}
