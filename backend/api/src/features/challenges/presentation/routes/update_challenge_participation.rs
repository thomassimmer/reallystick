use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{
            application::dto::{
                requests::challenge_participation::{
                    ChallengeParticipationUpdateRequest, UpdateChallengeParticipationParams,
                },
                responses::challenge_participation::ChallengeParticipationResponse,
            },
            infrastructure::repositories::challenge_participation_repository::ChallengeParticipationRepositoryImpl,
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

    let participation_repo = ChallengeParticipationRepositoryImpl::new(pool.get_ref().clone());

    let get_challenge_participation_result = participation_repo
        .get_by_id_with_executor(params.challenge_participation_id, &mut *transaction)
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
    challenge_participation.finished = body.finished;

    let update_challenge_participation_result = participation_repo
        .update_with_executor(&challenge_participation, &mut *transaction)
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
