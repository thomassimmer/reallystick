use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{
            helpers::challenge::{self, get_challenge_by_id},
            structs::{
                requests::challenge::{ChallengeUpdateRequest, UpdateChallengeParams},
                responses::challenge::ChallengeResponse,
            },
        },
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path, ReqData},
    HttpResponse, Responder,
};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;

#[put("/{challenge_id}")]
pub async fn update_challenge(
    pool: Data<PgPool>,
    params: Path<UpdateChallengeParams>,
    body: Json<ChallengeUpdateRequest>,
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

    let get_challenge_result = get_challenge_by_id(&mut *transaction, params.challenge_id).await;

    let mut challenge = match get_challenge_result {
        Ok(r) => match r {
            Some(challenge) => {
                if !request_claims.is_admin && challenge.creator != request_claims.user_id {
                    return HttpResponse::Forbidden()
                        .json(AppError::InvalidChallengeCreator.to_response());
                }
                challenge
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

    challenge.name = json!(body.name).to_string();
    challenge.description = json!(body.description).to_string();
    challenge.icon = body.icon.clone();
    challenge.start_date = body.start_date;

    let update_challenge_result = challenge::update_challenge(&mut *transaction, &challenge).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match update_challenge_result {
        Ok(_) => HttpResponse::Ok().json(ChallengeResponse {
            code: "CHALLENGE_UPDATED".to_string(),
            challenge: Some(challenge.to_challenge_data()),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::ChallengeUpdate.to_response())
        }
    }
}
