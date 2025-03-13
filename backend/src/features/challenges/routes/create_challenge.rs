use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        challenges::{
            helpers::challenge,
            structs::{
                models::challenge::Challenge, requests::challenge::ChallengeCreateRequest,
                responses::challenge::ChallengeResponse,
            },
        },
    },
};
use actix_web::{
    post,
    web::{Data, Json, ReqData},
    HttpResponse, Responder,
};
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

    let create_challenge_result = challenge::create_challenge(&mut *transaction, &challenge).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match create_challenge_result {
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
