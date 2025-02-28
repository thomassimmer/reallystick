use crate::{
    core::{constants::errors::AppError, helpers::mock_now::now},
    features::{
        auth::structs::models::Claims,
        challenges::helpers::challenge::get_challenge_by_id,
        habits::helpers::habit::get_habit_by_id,
        public_discussions::{
            helpers::public_message::{
                self, get_public_message_by_id, update_public_message_reply_count,
            },
            structs::{
                models::public_message::{PublicMessage, PUBLIC_MESSAGE_CONTENT_MAX_LENGTH},
                requests::public_message::PublicMessageCreateRequest,
                responses::public_message::PublicMessageResponse,
            },
        },
    },
};
use actix_web::{
    post,
    web::{Data, Json, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use uuid::Uuid;

#[post("/")]
pub async fn create_public_message(
    pool: Data<PgPool>,
    body: Json<PublicMessageCreateRequest>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Check if a habit or a challenge is given
    if body.habit_id.is_none() && body.challenge_id.is_none() {
        return HttpResponse::BadRequest().json(AppError::NoHabitNorChallengePassed.to_response());
    }

    // Check if a habit and a challenge were given
    if body.habit_id.is_some() && body.challenge_id.is_some() {
        return HttpResponse::BadRequest()
            .json(AppError::BothHabitAndChallengePassed.to_response());
    }

    // Check if habit exists
    if let Some(habit_id) = body.habit_id {
        match get_habit_by_id(&mut transaction, habit_id).await {
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
    if let Some(challenge_id) = body.challenge_id {
        match get_challenge_by_id(&mut transaction, challenge_id).await {
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

    // Check if replies_to exists
    let public_message_replying_to = if let Some(replies_to) = body.replies_to {
        Some(
            match get_public_message_by_id(&mut transaction, replies_to).await {
                Ok(r) => match r {
                    Some(r) => r,
                    None => {
                        return HttpResponse::NotFound()
                            .json(AppError::PublicMessageNotFound.to_response());
                    }
                },
                Err(e) => {
                    eprintln!("Error: {}", e);
                    return HttpResponse::InternalServerError()
                        .json(AppError::DatabaseQuery.to_response());
                }
            },
        )
    } else {
        None
    };

    // Check content size
    if body.content.len() > PUBLIC_MESSAGE_CONTENT_MAX_LENGTH {
        return HttpResponse::BadRequest()
            .json(AppError::PublicMessageContentTooLong.to_response());
    } else if body.content.is_empty() {
        return HttpResponse::BadRequest().json(AppError::PublicMessageContentEmpty.to_response());
    }

    let new_message_id = Uuid::new_v4();
    let thread_id = body.thread_id.unwrap_or(new_message_id);

    let new_public_message = PublicMessage {
        id: new_message_id,
        habit_id: body.habit_id,
        challenge_id: body.challenge_id,
        creator: request_claims.user_id,
        thread_id,
        replies_to: body.replies_to,
        created_at: now(),
        updated_at: None,
        content: body.content.to_owned(),
        like_count: 0,
        reply_count: 0,
        deleted_by_creator: false,
        deleted_by_admin: false,
        language_code: None,
    };

    let create_public_message_result =
        public_message::create_public_message(&mut transaction, &new_public_message).await;

    if let Err(e) = create_public_message_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PublicMessageCreation.to_response());
    }

    if let Some(mut message) = public_message_replying_to {
        message.reply_count += 1;

        let update_public_message_result =
            update_public_message_reply_count(&mut transaction, &message).await;

        if let Err(e) = update_public_message_result {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::PublicMessageUpdate.to_response());
        }
    }

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PublicMessageResponse {
        code: "PUBLIC_MESSAGE_CREATED".to_string(),
        message: Some(new_public_message.to_public_message_data()),
    })
}
