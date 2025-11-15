// Update challenge route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::challenges::application::dto::requests::challenge::{
    ChallengeUpdateRequest, UpdateChallengeParams,
};
use crate::features::challenges::application::dto::responses::challenge::ChallengeResponse;
use crate::features::challenges::application::use_cases::get_challenge::GetChallengeUseCase;
use crate::features::challenges::application::use_cases::update_challenge::UpdateChallengeUseCase;
use crate::features::challenges::domain::entities::challenge::CHALLENGE_DESCRIPTION_MAX_LENGTH;
use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;
use actix_web::web::{Data, Json, Path, ReqData};
use actix_web::{put, HttpResponse, Responder};
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

    let body = body.into_inner();

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let challenge_repo = ChallengeRepositoryImpl::new(pool_clone.clone());

    // Get existing challenge
    let challenge_repo_for_get = ChallengeRepositoryImpl::new(pool_clone.clone());
    let get_challenge_use_case = GetChallengeUseCase::new(challenge_repo_for_get);
    let mut challenge = match get_challenge_use_case
        .execute(params.challenge_id, &mut transaction)
        .await
    {
        Ok(Some(c)) => {
            // Check authorization
            if !request_claims.is_admin && c.creator != request_claims.user_id {
                if let Err(e) = transaction.rollback().await {
                    error!("Error rolling back: {}", e);
                }
                return HttpResponse::Forbidden()
                    .json(AppError::InvalidChallengeCreator.to_response());
            }
            c
        }
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::ChallengeNotFound.to_response());
        }
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Validate description length
    if body
        .description
        .iter()
        .any(|(_language_code, description)| description.len() > CHALLENGE_DESCRIPTION_MAX_LENGTH)
    {
        if let Err(e) = transaction.rollback().await {
            error!("Error rolling back: {}", e);
        }
        return HttpResponse::BadRequest()
            .json(AppError::ChallengeDescriptionTooLong.to_response());
    }

    // Update challenge fields
    challenge.name = json!(body.name).to_string();
    challenge.description = json!(body.description).to_string();
    challenge.icon = body.icon.clone();
    challenge.start_date = body.start_date;

    // Execute update use case
    let update_challenge_use_case = UpdateChallengeUseCase::new(challenge_repo);
    let result = update_challenge_use_case
        .execute(&challenge, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
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
