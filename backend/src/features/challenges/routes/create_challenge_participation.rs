use crate::{
    core::constants::errors::AppError,
    features::{
        challenges::{
            helpers::{challenge::get_challenge_by_id, challenge_participation},
            structs::{
                models::challenge_participation::ChallengeParticipation,
                requests::challenge_participation::ChallengeParticipationCreateRequest,
                responses::challenge_participation::ChallengeParticipationResponse,
            },
        },
        profile::structs::models::User,
    },
};
use actix_web::{
    post,
    web::{Data, Json},
    HttpResponse, Responder,
};
use chrono::Utc;
use sqlx::PgPool;
use uuid::Uuid;

#[post("/")]
pub async fn create_challenge_participation(
    pool: Data<PgPool>,
    body: Json<ChallengeParticipationCreateRequest>,
    request_user: User,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    match get_challenge_by_id(&mut transaction, body.challenge_id).await {
        Ok(r) => match r {
            Some(_) => {}
            None => {
                return HttpResponse::NotFound().json(AppError::ChallengeNotFound.to_response())
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let challenge_participation = ChallengeParticipation {
        id: Uuid::new_v4(),
        user_id: request_user.id,
        challenge_id: body.challenge_id,
        color: body.color.clone(),
        start_date: body.start_date,
        created_at: Utc::now(),
    };

    let create_challenge_participation_result =
        challenge_participation::create_challenge_participation(
            &mut transaction,
            &challenge_participation,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match create_challenge_participation_result {
        Ok(_) => HttpResponse::Ok().json(ChallengeParticipationResponse {
            code: "CHALLENGE_PARTICIPATION_CREATED".to_string(),
            challenge_participation: Some(
                challenge_participation.to_challenge_participation_data(),
            ),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::ChallengeParticipationCreation.to_response())
        }
    }
}
