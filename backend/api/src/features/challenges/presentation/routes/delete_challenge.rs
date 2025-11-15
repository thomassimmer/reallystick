// Delete challenge route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::challenges::application::dto::requests::challenge::GetChallengeParams;
use crate::features::challenges::application::dto::responses::challenge::ChallengeResponse;
use crate::features::challenges::application::use_cases::delete_challenge::DeleteChallengeUseCase;
use crate::features::challenges::application::use_cases::get_challenge::GetChallengeUseCase;
use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;
use actix_web::web::{Data, Path, ReqData};
use actix_web::{delete, HttpResponse, Responder};
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

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let challenge_repo = ChallengeRepositoryImpl::new(pool_clone.clone());

    // Check authorization - get challenge first
    let challenge_repo_for_get = ChallengeRepositoryImpl::new(pool_clone.clone());
    let get_challenge_use_case = GetChallengeUseCase::new(challenge_repo_for_get);
    match get_challenge_use_case
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
    }

    // Execute delete use case
    let delete_challenge_use_case = DeleteChallengeUseCase::new(challenge_repo);
    let result = delete_challenge_use_case
        .execute(params.challenge_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(ChallengeResponse {
            code: "CHALLENGE_DELETED".to_string(),
            challenge: None,
        }),
        Err(e) => {
            error!("Error: {}", e);
            // Check if it's a not found error
            if e.contains("not found") || e.contains("No rows affected") {
                HttpResponse::NotFound().json(AppError::ChallengeNotFound.to_response())
            } else {
                HttpResponse::InternalServerError().json(AppError::ChallengeDelete.to_response())
            }
        }
    }
}
