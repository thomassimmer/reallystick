// Get challenges route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::challenges::application::dto::responses::challenge::ChallengesResponse;
use crate::features::challenges::application::use_cases::get_challenges::GetChallengesUseCase;
use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;
use actix_web::web::{Data, ReqData};
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_challenges(pool: Data<PgPool>, request_claims: ReqData<Claims>) -> impl Responder {
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
    let get_challenges_use_case = GetChallengesUseCase::new(challenge_repo);

    // Execute use case - get challenges for the logged-in user
    let result = get_challenges_use_case
        .execute(Some(request_claims.user_id), &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(challenges) => HttpResponse::Ok().json(ChallengesResponse {
            code: "CHALLENGES_FETCHED".to_string(),
            challenges: challenges.iter().map(|c| c.to_challenge_data()).collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
