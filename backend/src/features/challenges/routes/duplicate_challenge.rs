use std::sync::Arc;

use crate::{
    core::{
        constants::errors::AppError,
        helpers::{mock_now::now, translation::Translator},
    },
    features::{
        auth::structs::models::Claims,
        challenges::{
            helpers::{
                challenge::{self, get_challenge_by_id},
                challenge_daily_tracking::{
                    create_challenge_daily_trackings, get_challenge_daily_trackings_for_challenge,
                },
            },
            structs::{
                models::{challenge::Challenge, challenge_daily_tracking::ChallengeDailyTracking},
                requests::challenge::ChallengeDuplicateParams,
                responses::challenge::ChallengeResponse,
            },
        },
        notifications::helpers::notification::generate_notification,
        profile::structs::models::UserPublicDataCache,
    },
};
use actix_web::{
    get,
    web::{Data, Path, ReqData},
    HttpResponse, Responder,
};
use fluent::FluentArgs;
use redis::Client;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[get("/duplicate/{challenge_id}")]
pub async fn duplicate_challenge(
    pool: Data<PgPool>,
    params: Path<ChallengeDuplicateParams>,
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

    let get_challenge_result = get_challenge_by_id(&mut *transaction, params.challenge_id).await;

    let challenge_to_duplicate = match get_challenge_result {
        Ok(r) => match r {
            Some(challenge) => challenge,
            None => {
                return HttpResponse::NotFound().json(AppError::ChallengeNotFound.to_response())
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let challenge_to_create = Challenge {
        id: Uuid::new_v4(),
        name: challenge_to_duplicate.name,
        description: challenge_to_duplicate.description,
        start_date: challenge_to_duplicate.start_date,
        icon: challenge_to_duplicate.icon,
        created_at: now(),
        creator: request_claims.user_id,
        deleted: false,
    };

    let create_challenge_result =
        challenge::create_challenge(&mut *transaction, &challenge_to_create).await;

    if let Err(e) = create_challenge_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::ChallengeCreation.to_response());
    }

    let get_challenge_daily_trackings_result =
        get_challenge_daily_trackings_for_challenge(&mut *transaction, params.challenge_id).await;

    let challenge_daily_tracking_to_duplicate = match get_challenge_daily_trackings_result {
        Ok(challenge_daily_tracking) => challenge_daily_tracking,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let mut challenge_daily_trackings_to_create = Vec::<ChallengeDailyTracking>::new();

    for cdt in challenge_daily_tracking_to_duplicate {
        challenge_daily_trackings_to_create.push(ChallengeDailyTracking {
            id: Uuid::new_v4(),
            habit_id: cdt.habit_id,
            challenge_id: challenge_to_create.id,
            day_of_program: cdt.day_of_program,
            created_at: now(),
            quantity_of_set: cdt.quantity_of_set,
            quantity_per_set: cdt.quantity_per_set,
            unit_id: cdt.unit_id,
            weight: cdt.weight,
            weight_unit_id: cdt.weight_unit_id,
            note: cdt.note,
        });
    }

    let create_challenge_daily_tracking_result =
        create_challenge_daily_trackings(&mut *transaction, &challenge_daily_trackings_to_create)
            .await;

    if let Err(e) = create_challenge_daily_tracking_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::ChallengeDailyTrackingCreation.to_response());
    }

    // If user is not the challenge's creator
    if request_claims.user_id != challenge_to_duplicate.creator {
        if let (Some(duplicator), Some(creator)) = (
            user_public_data_cache
                .get_value_for_key_or_insert_it(&request_claims.user_id, &mut *transaction)
                .await,
            user_public_data_cache
                .get_value_for_key_or_insert_it(&challenge_to_duplicate.creator, &mut *transaction)
                .await,
        ) {
            let mut args = FluentArgs::new();
            args.set("username", duplicator.username);

            let url = Some(format!("/challenges/{}/null", challenge_to_create.id));

            generate_notification(
                &mut *transaction,
                challenge_to_duplicate.creator,
                &translator.translate(
                    &creator.locale,
                    "user-duplicated-your-challenge-title",
                    None,
                ),
                &translator.translate(
                    &creator.locale,
                    "user-duplicated-your-challenge-body",
                    Some(args),
                ),
                redis_client,
                "challenge_duplicated",
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

    HttpResponse::Ok().json(ChallengeResponse {
        code: "CHALLENGE_CREATED".to_string(),
        challenge: Some(challenge_to_create.to_challenge_data()),
    })
}
