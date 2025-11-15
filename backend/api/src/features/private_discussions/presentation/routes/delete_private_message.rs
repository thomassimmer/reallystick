// Delete private message route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::core::structs::redis_messages::NotificationEvent;
use crate::features::auth::domain::entities::Claims;
use crate::features::private_discussions::application::use_cases::delete_private_message::DeletePrivateMessageUseCase;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_participation_repository::PrivateDiscussionParticipationRepositoryImpl;
use crate::features::private_discussions::infrastructure::repositories::private_message_repository::PrivateMessageRepositoryImpl;
use crate::features::private_discussions::application::dto::requests::private_message::DeletePrivateMessageParams;
use crate::features::private_discussions::application::dto::responses::private_message::PrivateMessageResponse;
use actix_web::web::{Data, Query, ReqData};
use actix_web::{delete, HttpResponse, Responder};
use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;

#[delete("/")]
pub async fn delete_private_message(
    pool: Data<PgPool>,
    query: Query<DeletePrivateMessageParams>,
    redis_client: Data<Client>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let params = query.into_inner();

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
    let participation_repo = PrivateDiscussionParticipationRepositoryImpl::new(pool_clone.clone());

    // Get message for notification
    let private_message = match message_repo
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

    // Execute use case
    let delete_message_use_case = DeletePrivateMessageUseCase::new(message_repo);
    let result = delete_message_use_case
        .execute(params.message_id, request_claims.user_id, &mut transaction)
        .await;

    // Get recipients for notification
    let recipients = participation_repo
        .get_recipients_with_executor(
            vec![private_message.discussion_id],
            request_claims.user_id,
            &mut *transaction,
        )
        .await
        .unwrap_or_default();

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => {
            // Publish Redis event
            if let Ok(mut con) = redis_client
                .get_ref()
                .get_multiplexed_async_connection()
                .await
            {
                let mut deleted_message = private_message.clone();
                deleted_message.deleted = true;

                let _: Result<(), redis::RedisError> = con
                    .publish(
                        "private_message_deleted",
                        json!(NotificationEvent {
                            data: json!(deleted_message.to_private_message_data()).to_string(),
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
                            "private_message_deleted",
                            json!(NotificationEvent {
                                data: json!(deleted_message.to_private_message_data()).to_string(),
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
                code: "PRIVATE_MESSAGE_DELETED".to_string(),
                message: None,
            })
        }
        Err(AppError::PrivateMessageNotFound) => {
            HttpResponse::NotFound().json(AppError::PrivateMessageNotFound.to_response())
        }
        Err(AppError::PrivateMessageDeletionNotDoneByCreator) => HttpResponse::Unauthorized()
            .json(AppError::PrivateMessageDeletionNotDoneByCreator.to_response()),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
