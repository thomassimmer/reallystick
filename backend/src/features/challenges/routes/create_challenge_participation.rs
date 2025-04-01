use std::sync::Arc;

use crate::{
    core::{constants::errors::AppError, helpers::translation::Translator},
    features::{
        auth::structs::models::Claims,
        challenges::{
            helpers::{
                challenge::get_challenge_by_id,
                challenge_participation::{
                    self, get_ongoing_challenge_participation_for_user_and_challenge,
                },
            },
            structs::{
                models::challenge_participation::ChallengeParticipation,
                requests::challenge_participation::ChallengeParticipationCreateRequest,
                responses::challenge_participation::ChallengeParticipationResponse,
            },
        },
        notifications::helpers::notification::generate_notification,
        profile::structs::models::UserPublicDataCache,
    },
};
use actix_web::{
    post,
    web::{Data, Json, ReqData},
    HttpResponse, Responder,
};
use chrono::Utc;
use fluent::FluentArgs;
use redis::Client;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_challenge_participation(
    pool: Data<PgPool>,
    body: Json<ChallengeParticipationCreateRequest>,
    redis_client: Data<Client>,
    translator: Data<Arc<Translator>>,
    user_public_data_cache: Data<UserPublicDataCache>,
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

    let challenge = match get_challenge_by_id(&mut *transaction, body.challenge_id).await {
        Ok(r) => match r {
            Some(c) => c,
            None => {
                return HttpResponse::NotFound().json(AppError::ChallengeNotFound.to_response())
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    match get_ongoing_challenge_participation_for_user_and_challenge(
        &mut *transaction,
        request_claims.user_id,
        body.challenge_id,
    )
    .await
    {
        Ok(r) => {
            if r.is_some() {
                return HttpResponse::BadRequest()
                    .json(AppError::ChallengeParticipationAlreadyExisting.to_response());
            }
        }
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    }

    let challenge_participation = ChallengeParticipation {
        id: Uuid::new_v4(),
        user_id: request_claims.user_id,
        challenge_id: body.challenge_id,
        color: body.color.clone(),
        start_date: body.start_date,
        created_at: Utc::now(),
        notifications_reminder_enabled: false,
        reminder_time: None,
        reminder_body: None,
        finished: false,
    };

    let create_challenge_participation_result =
        challenge_participation::create_challenge_participation(
            &mut *transaction,
            &challenge_participation,
        )
        .await;

    if let Err(e) = create_challenge_participation_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::ChallengeParticipationCreation.to_response());
    }

    // If user is not the challenge's creator
    if request_claims.user_id != challenge.creator {
        if let (Some(joiner), Some(creator)) = (
            user_public_data_cache
                .get_value_for_key_or_insert_it(&request_claims.user_id, &mut *transaction)
                .await,
            user_public_data_cache
                .get_value_for_key_or_insert_it(&challenge.creator, &mut *transaction)
                .await,
        ) {
            let mut args = FluentArgs::new();
            args.set("username", joiner.username);

            let url = Some(format!("/challenges/{}/null", challenge.id));

            generate_notification(
                &mut *transaction,
                challenge.creator,
                &translator.translate(&creator.locale, "user-joined-your-challenge-title", None),
                &translator.translate(
                    &creator.locale,
                    "user-joined-your-challenge-body",
                    Some(args),
                ),
                redis_client,
                "challenge_joined",
                url,
            )
            .await;
        }
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(ChallengeParticipationResponse {
        code: "CHALLENGE_PARTICIPATION_CREATED".to_string(),
        challenge_participation: Some(challenge_participation.to_challenge_participation_data()),
    })
}
