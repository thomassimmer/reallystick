// Create challenge route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::challenges::application::dto::requests::challenge::ChallengeCreateRequest;
use crate::features::challenges::application::dto::responses::challenge::ChallengeResponse;
use crate::features::challenges::application::use_cases::create_challenge::CreateChallengeUseCase;
use crate::features::challenges::domain::entities::challenge::{
    Challenge, CHALLENGE_DESCRIPTION_MAX_LENGTH,
};
use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
use chrono::Utc;
use serde_json::json;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_challenge(
    pool: Data<PgPool>,
    body: Json<ChallengeCreateRequest>,
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

    // Validate description length
    if body
        .description
        .iter()
        .any(|(_language_code, description)| description.len() > CHALLENGE_DESCRIPTION_MAX_LENGTH)
    {
        return HttpResponse::BadRequest()
            .json(AppError::ChallengeDescriptionTooLong.to_response());
    }

    // Create challenge entity
    let challenge = Challenge {
        id: Uuid::new_v4(),
        name: json!(body.name).to_string(),
        description: json!(body.description).to_string(),
        start_date: body.start_date,
        icon: body.icon.clone(),
        created_at: Utc::now(),
        creator: request_claims.user_id,
        deleted: false,
    };

    // Create repository and use case
    let pool_clone = pool.get_ref().clone();
    let challenge_repo = ChallengeRepositoryImpl::new(pool_clone);
    let create_challenge_use_case = CreateChallengeUseCase::new(challenge_repo);

    // Execute use case
    let result = create_challenge_use_case
        .execute(&challenge, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(ChallengeResponse {
            code: "CHALLENGE_CREATED".to_string(),
            challenge: Some(challenge.to_challenge_data()),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::ChallengeCreation.to_response())
        }
    }
}
