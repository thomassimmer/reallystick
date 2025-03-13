use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{
            helpers::challenge_participation::{self, get_challenge_participation_by_id},
            structs::{
                requests::challenge_participation::{
                    ChallengeParticipationUpdateRequest, UpdateChallengeParticipationParams,
                },
                responses::challenge_participation::ChallengeParticipationResponse,
            },
        },
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[put("/{challenge_participation_id}")]
pub async fn update_challenge_participation(
    pool: Data<PgPool>,
    params: Path<UpdateChallengeParticipationParams>,
    body: Json<ChallengeParticipationUpdateRequest>,
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

    let get_challenge_participation_result =
        get_challenge_participation_by_id(&mut *transaction, params.challenge_participation_id)
            .await;

    let mut challenge_participation = match get_challenge_participation_result {
        Ok(r) => match r {
            Some(challenge_participation) => {
                if !request_claims.is_admin
                    && challenge_participation.user_id != request_claims.user_id
                {
                    return HttpResponse::Forbidden()
                        .json(AppError::InvalidChallengeParticipationUser.to_response());
                }
                challenge_participation
            }
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::ChallengeParticipationNotFound.to_response())
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    challenge_participation.color = body.color.clone();
    challenge_participation.start_date = body.start_date;
    challenge_participation.notifications_reminder_enabled = body.notifications_reminder_enabled;
    challenge_participation.reminder_time = body.reminder_time;
    challenge_participation.reminder_body = body.reminder_body.clone();

    let update_challenge_participation_result =
        challenge_participation::update_challenge_participation(
            &mut *transaction,
            &challenge_participation,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match update_challenge_participation_result {
        Ok(_) => HttpResponse::Ok().json(ChallengeParticipationResponse {
            code: "CHALLENGE_PARTICIPATION_UPDATED".to_string(),
            challenge_participation: Some(
                challenge_participation.to_challenge_participation_data(),
            ),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::ChallengeParticipationUpdate.to_response())
        }
    }
}
