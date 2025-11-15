// Update private message route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::core::helpers::mock_now::now;
use crate::core::structs::redis_messages::NotificationEvent;
use crate::features::auth::domain::entities::Claims;
use crate::features::private_discussions::application::use_cases::update_private_message::UpdatePrivateMessageUseCase;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_participation_repository::PrivateDiscussionParticipationRepositoryImpl;
use crate::features::private_discussions::infrastructure::repositories::private_message_repository::PrivateMessageRepositoryImpl;
use crate::features::private_discussions::application::dto::requests::private_message::{
    PrivateMessageUpdateRequest, UpdatePrivateMessageParams,
};
use crate::features::private_discussions::application::dto::responses::private_message::PrivateMessageResponse;
use actix_web::web::{Data, Json, Path, ReqData};
use actix_web::{put, HttpResponse, Responder};
use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;

#[put("/{message_id}")]
pub async fn update_private_message(
    pool: Data<PgPool>,
    params: Path<UpdatePrivateMessageParams>,
    body: Json<PrivateMessageUpdateRequest>,
    redis_client: Data<Client>,
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
    let _participation_repo = PrivateDiscussionParticipationRepositoryImpl::new(pool_clone.clone());

    // Get existing message
    let existing_message = match message_repo
        .get_by_id_with_executor(params.message_id, &mut *transaction)
        .await
    {
        Ok(Some(m)) => m,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::PrivateMessageNotFound.to_response());
        }
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Update message
    let mut updated_message = existing_message.clone();
    updated_message.updated_at = Some(now());
    updated_message.content = body.content.clone();

    // Execute use case
    let update_message_use_case = UpdatePrivateMessageUseCase::new(message_repo);
    let result = update_message_use_case
        .execute(&updated_message, request_claims.user_id, &mut transaction)
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
                            vec![updated_message.discussion_id],
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
                        "private_message_updated",
                        json!(NotificationEvent {
                            data: json!(updated_message.to_private_message_data()).to_string(),
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
                            "private_message_updated",
                            json!(NotificationEvent {
                                data: json!(updated_message.to_private_message_data()).to_string(),
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
                code: "PRIVATE_MESSAGE_UPDATED".to_string(),
                message: Some(updated_message.to_private_message_data()),
            })
        }
        Err(AppError::PrivateMessageNotFound) => {
            HttpResponse::NotFound().json(AppError::PrivateMessageNotFound.to_response())
        }
        Err(AppError::PrivateMessageUpdateNotDoneByCreator) => HttpResponse::Unauthorized()
            .json(AppError::PrivateMessageUpdateNotDoneByCreator.to_response()),
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
