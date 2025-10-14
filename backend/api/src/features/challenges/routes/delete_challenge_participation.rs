use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{
            helpers::challenge_participation::{
                delete_challenge_participation_by_id, get_challenge_participation_by_id,
            },
            structs::{
                requests::challenge_participation::GetChallengeParticipationParams,
                responses::challenge_participation::ChallengeParticipationResponse,
            },
        },
    },
};
use actix_web::{
    delete,
    web::{Data, Path, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[delete("/{challenge_participation_id}")]
pub async fn delete_challenge_participation(
    pool: Data<PgPool>,
    params: Path<GetChallengeParticipationParams>,
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

    match get_challenge_participation_by_id(&mut *transaction, params.challenge_participation_id)
        .await
    {
        Ok(r) => match r {
            Some(challenge_participation) => {
                if !request_claims.is_admin
                    && challenge_participation.user_id != request_claims.user_id
                {
                    return HttpResponse::Forbidden()
                        .json(AppError::InvalidChallengeCreator.to_response());
                }
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

    let delete_challenge_participation_result =
        delete_challenge_participation_by_id(&mut *transaction, params.challenge_participation_id)
            .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match delete_challenge_participation_result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                HttpResponse::Ok().json(ChallengeParticipationResponse {
                    code: "CHALLENGE_PARTICIPATION_DELETED".to_string(),
                    challenge_participation: None,
                })
            } else {
                HttpResponse::NotFound()
                    .json(AppError::ChallengeParticipationNotFound.to_response())
            }
        }
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::ChallengeParticipationDelete.to_response())
        }
    }
}
