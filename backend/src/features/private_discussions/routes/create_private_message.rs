use std::sync::Arc;

use crate::{
    core::{
        constants::errors::AppError,
        helpers::{mock_now::now, translation::Translator},
        structs::redis_messages::NotificationEvent,
    },
    features::{
        auth::structs::models::Claims,
        private_discussions::{
            helpers::{
                private_discussion::get_private_discussion_by_id, private_discussion_participation,
                private_message,
            },
            structs::{
                models::private_message::{PrivateMessage, PRIVATE_MESSAGE_CONTENT_MAX_LENGTH},
                requests::private_message::PrivateMessageCreateRequest,
                responses::private_message::PrivateMessageResponse,
            },
        },
        profile::structs::models::UserPublicDataCache,
    },
};
use actix_web::{
    post,
    web::{Data, Json, ReqData},
    HttpResponse, Responder,
};
use fluent::FluentArgs;
use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::PgPool;
use uuid::Uuid;

#[post("/")]
pub async fn create_private_message(
    pool: Data<PgPool>,
    body: Json<PrivateMessageCreateRequest>,
    redis_client: Data<Client>,
    translator: Data<Arc<Translator>>,
    user_public_data_cache: Data<UserPublicDataCache>,
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

    // Check if discussion exists
    match get_private_discussion_by_id(&mut *transaction, body.discussion_id).await {
        Ok(r) => {
            if r.is_none() {
                return HttpResponse::NotFound()
                    .json(AppError::PrivateDiscussionNotFound.to_response());
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Check content size
    if body.content.len() > PRIVATE_MESSAGE_CONTENT_MAX_LENGTH {
        return HttpResponse::BadRequest()
            .json(AppError::PrivateMessageContentTooLong.to_response());
    } else if body.content.is_empty() {
        return HttpResponse::BadRequest().json(AppError::PrivateMessageContentEmpty.to_response());
    }

    let private_message = PrivateMessage {
        id: Uuid::new_v4(),
        discussion_id: body.discussion_id,
        creator: request_claims.user_id,
        created_at: now(),
        updated_at: None,
        content: body.content.to_owned(),
        creator_encrypted_session_key: body.creator_encrypted_session_key.to_owned(),
        recipient_encrypted_session_key: body.recipient_encrypted_session_key.to_owned(),
        deleted: false,
        seen: false,
    };

    let create_private_message_result =
        private_message::create_private_message(&mut *transaction, &private_message).await;

    if let Err(e) = create_private_message_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateMessageCreation.to_response());
    }

    let recipients = match private_discussion_participation::get_private_discussions_recipients(
        &mut *transaction,
        vec![body.discussion_id],
        request_claims.user_id,
    )
    .await
    {
        Ok(r) => r,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    match redis_client.get_multiplexed_async_connection().await {
        Ok(mut con) => {
            let result: Result<(), redis::RedisError> = con
                .publish(
                    "private_message_created",
                    json!(NotificationEvent {
                        data: json!(private_message.to_private_message_data()).to_string(),
                        recipient: request_claims.user_id,
                        title: None,
                        body: None,
                        url: None,
                    })
                    .to_string(),
                )
                .await;
            if let Err(e) = result {
                eprintln!("Error: {}", e);
            }

            if let Some(recipient_participation) = recipients.iter().next() {
                if let (Some(recipient), Some(creator)) = (
                    user_public_data_cache
                        .get_value_for_key_or_insert_it(
                            &recipient_participation.user_id,
                            &mut *transaction,
                        )
                        .await,
                    user_public_data_cache
                        .get_value_for_key_or_insert_it(&request_claims.user_id, &mut *transaction)
                        .await,
                ) {
                    let mut args = FluentArgs::new();
                    args.set("username", creator.username);

                    let url = format!("/messages/{}", private_message.discussion_id);

                    let result: Result<(), redis::RedisError> = con
                        .publish(
                            "private_message_created",
                            json!(NotificationEvent {
                                data: json!(private_message.to_private_message_data()).to_string(),
                                recipient: recipient_participation.user_id,
                                title: Some(translator.translate(
                                    &recipient.locale,
                                    "message-created-title",
                                    None,
                                )),
                                body: Some(translator.translate(
                                    &recipient.locale,
                                    "message-created-body",
                                    Some(&args),
                                )),
                                url: Some(url),
                            })
                            .to_string(),
                        )
                        .await;
                    if let Err(e) = result {
                        eprintln!("Error: {}", e);
                    }
                }
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
        }
    }

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PrivateMessageResponse {
        code: "PRIVATE_MESSAGE_CREATED".to_string(),
        message: Some(private_message.to_private_message_data()),
    })
}
