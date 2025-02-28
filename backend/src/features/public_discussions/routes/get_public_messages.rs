use crate::{
    core::constants::errors::AppError,
    features::{
        challenges::helpers::challenge::get_challenge_by_id,
        habits::helpers::habit::get_habit_by_id,
        public_discussions::{
            helpers::public_message::{self},
            structs::{
                requests::public_message::GetPublicMessagesParams,
                responses::public_message::PublicMessagesResponse,
            },
        },
    },
};
use actix_web::{
    get,
    web::{Data, Query},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/")]
pub async fn get_public_messages(
    pool: Data<PgPool>,
    query: Query<GetPublicMessagesParams>,
) -> impl Responder {
    let params = query.into_inner();

    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Check if a habit or a challenge is given
    if params.habit_id.is_none() && params.challenge_id.is_none() {
        return HttpResponse::BadRequest().json(AppError::NoHabitNorChallengePassed.to_response());
    }

    // Check if a habit and a challenge were given
    if params.habit_id.is_some() && params.challenge_id.is_some() {
        return HttpResponse::BadRequest()
            .json(AppError::BothHabitAndChallengePassed.to_response());
    }

    // Check if habit exists
    if let Some(habit_id) = params.habit_id {
        match get_habit_by_id(&mut *transaction, habit_id).await {
            Ok(r) => {
                if r.is_none() {
                    return HttpResponse::NotFound().json(AppError::HabitNotFound.to_response());
                }
            }
            Err(e) => {
                eprintln!("Error: {}", e);
                return HttpResponse::InternalServerError()
                    .json(AppError::DatabaseQuery.to_response());
            }
        };
    }

    // Check if challenge exists
    if let Some(challenge_id) = params.challenge_id {
        match get_challenge_by_id(&mut *transaction, challenge_id).await {
            Ok(r) => {
                if r.is_none() {
                    return HttpResponse::NotFound()
                        .json(AppError::ChallengeNotFound.to_response());
                }
            }
            Err(e) => {
                eprintln!("Error: {}", e);
                return HttpResponse::InternalServerError()
                    .json(AppError::DatabaseQuery.to_response());
            }
        };
    }

    let get_messages_result = if let Some(challenge_id) = params.challenge_id {
        public_message::get_first_public_messages_of_challenge(&mut *transaction, challenge_id).await
    } else if let Some(habit_id) = params.habit_id {
        public_message::get_first_public_messages_of_habit(&mut *transaction, habit_id).await
    } else {
        Ok(vec![])
    };

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match get_messages_result {
        Ok(messages) => HttpResponse::Ok().json(PublicMessagesResponse {
            code: "PUBLIC_MESSAGE_FETCHED".to_string(),
            messages: messages
                .iter()
                .map(|m| m.to_public_message_data())
                .collect(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::PublicMessageCreation.to_response())
        }
    }
}
