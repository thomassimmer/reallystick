// Get challenge route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::challenges::application::dto::requests::challenge::GetChallengeParams;
use crate::features::challenges::application::dto::responses::challenge::ChallengeResponse;
use crate::features::challenges::application::use_cases::get_challenge::GetChallengeUseCase;
use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;
use actix_web::web::{Data, Path};
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/{challenge_id}")]
pub async fn get_challenge(pool: Data<PgPool>, params: Path<GetChallengeParams>) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repository and use case
    let pool_clone = pool.get_ref().clone();
    let challenge_repo = ChallengeRepositoryImpl::new(pool_clone);
    let get_challenge_use_case = GetChallengeUseCase::new(challenge_repo);

    // Execute use case
    let result = get_challenge_use_case
        .execute(params.challenge_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(Some(challenge)) => HttpResponse::Ok().json(ChallengeResponse {
            code: "CHALLENGE_FETCHED".to_string(),
            challenge: Some(challenge.to_challenge_data()),
        }),
        Ok(None) => HttpResponse::NotFound().json(AppError::ChallengeNotFound.to_response()),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
