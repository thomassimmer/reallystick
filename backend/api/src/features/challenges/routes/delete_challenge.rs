use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{
            helpers::challenge::{delete_challenge_by_id, get_challenge_by_id},
            structs::{
                requests::challenge::GetChallengeParams, responses::challenge::ChallengeResponse,
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

#[delete("/{challenge_id}")]
pub async fn delete_challenge(
    pool: Data<PgPool>,
    params: Path<GetChallengeParams>,
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

    match get_challenge_by_id(&mut *transaction, params.challenge_id).await {
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

    let delete_challenge_result =
        delete_challenge_by_id(&mut *transaction, params.challenge_id).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match delete_challenge_result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                HttpResponse::Ok().json(ChallengeResponse {
                    code: "CHALLENGE_DELETED".to_string(),
                    challenge: None,
                })
            } else {
                HttpResponse::NotFound().json(AppError::ChallengeNotFound.to_response())
            }
        }
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::ChallengeDelete.to_response())
        }
    }
}
