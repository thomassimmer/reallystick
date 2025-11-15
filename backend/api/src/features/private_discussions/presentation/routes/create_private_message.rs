// Create private message route - uses clean architecture

use std::sync::Arc;

use crate::core::constants::errors::AppError;
use crate::core::helpers::{mock_now::now, translation::Translator};
use crate::core::structs::redis_messages::NotificationEvent;
use crate::features::auth::domain::entities::Claims;
use crate::features::private_discussions::application::use_cases::create_private_message::CreatePrivateMessageUseCase;
use crate::features::private_discussions::domain::entities::private_message::PrivateMessage;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_participation_repository::PrivateDiscussionParticipationRepositoryImpl;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_repository::PrivateDiscussionRepositoryImpl;
use crate::features::private_discussions::infrastructure::repositories::private_message_repository::PrivateMessageRepositoryImpl;
use crate::features::private_discussions::application::dto::requests::private_message::PrivateMessageCreateRequest;
use crate::features::private_discussions::application::dto::responses::private_message::PrivateMessageResponse;
use crate::features::profile::domain::entities::UserPublicDataCache;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_private_message(
    pool: Data<PgPool>,
    body: Json<PrivateMessageCreateRequest>,
    redis_client: Data<Client>,
    _translator: Data<Arc<Translator>>,
    _user_public_data_cache: Data<UserPublicDataCache>,
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

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let message_repo = PrivateMessageRepositoryImpl::new(pool_clone.clone());
    let discussion_repo = PrivateDiscussionRepositoryImpl::new(pool_clone.clone());
    let _participation_repo = PrivateDiscussionParticipationRepositoryImpl::new(pool_clone.clone());

    // Create message entity
    let private_message = PrivateMessage {
        id: Uuid::new_v4(),
        discussion_id: body.discussion_id,
        creator: request_claims.user_id,
        created_at: now(),
        updated_at: None,
        content: body.content.clone(),
        creator_encrypted_session_key: body.creator_encrypted_session_key.clone(),
        recipient_encrypted_session_key: body.recipient_encrypted_session_key.clone(),
        deleted: false,
        seen: false,
    };

    // Execute use case
    let create_message_use_case = CreatePrivateMessageUseCase::new(message_repo, discussion_repo);
    let result = create_message_use_case
        .execute(&private_message, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => {
            // Get recipient for notification - use a new transaction since we already committed
            let participation_repo_for_notif =
                PrivateDiscussionParticipationRepositoryImpl::new(pool.get_ref().clone());
            let recipients = match pool.begin().await {
                Ok(mut notif_transaction) => {
                    match participation_repo_for_notif
                        .get_recipients_with_executor(
                            vec![private_message.discussion_id],
                            request_claims.user_id,
                            &mut *notif_transaction,
                        )
                        .await
                    {
                        Ok(r) => {
                            let _ = notif_transaction.commit().await;
                            r
                        }
                        Err(_) => {
                            let _ = notif_transaction.rollback().await;
                            vec![]
                        }
                    }
                }
                Err(_) => vec![],
            };

            // Publish Redis event
            if let Ok(mut con) = redis_client
                .get_ref()
                .get_multiplexed_async_connection()
                .await
            {
                let _: Result<(), redis::RedisError> = con
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

                if let Some(recipient) = recipients.first() {
                    let _: Result<(), redis::RedisError> = con
                        .publish(
                            "private_message_created",
                            json!(NotificationEvent {
                                data: json!(private_message.to_private_message_data()).to_string(),
                                recipient: recipient.user_id,
                                title: None,
                                body: None,
                                url: None,
                            })
                            .to_string(),
                        )
                        .await;
                }
            }

            HttpResponse::Ok().json(PrivateMessageResponse {
                code: "PRIVATE_MESSAGE_CREATED".to_string(),
                message: Some(private_message.to_private_message_data()),
            })
        }
        Err(AppError::PrivateDiscussionNotFound) => {
            HttpResponse::NotFound().json(AppError::PrivateDiscussionNotFound.to_response())
        }
        Err(AppError::PrivateMessageContentEmpty) => {
            HttpResponse::BadRequest().json(AppError::PrivateMessageContentEmpty.to_response())
        }
        Err(AppError::PrivateMessageContentTooLong) => {
            HttpResponse::BadRequest().json(AppError::PrivateMessageContentTooLong.to_response())
        }
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
