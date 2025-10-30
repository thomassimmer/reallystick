use crate::{
    core::{constants::errors::AppError, structs::redis_messages::NotificationEvent},
    features::{
        auth::structs::models::Claims,
        private_discussions::{
            helpers::{
                private_discussion_participation,
                private_message::{self, get_private_message_by_id},
            },
            structs::{
                requests::private_message::DeletePrivateMessageParams,
                responses::private_message::PrivateMessageResponse,
            },
        },
    },
};
use actix_web::{
    delete,
    web::{Data, Query, ReqData},
    HttpResponse, Responder,
};
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

    // Check if message exists
    let mut private_message = match get_private_message_by_id(&mut *transaction, params.message_id)
        .await
    {
        Ok(r) => match r {
            Some(private_message) => private_message,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::PrivateMessageNotFound.to_response());
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // check request user is creator
    if private_message.creator != request_claims.user_id {
        return HttpResponse::Unauthorized()
            .json(AppError::PrivateMessageDeletionNotDoneByCreator.to_response());
    }

    let delete_private_message_result =
        private_message::delete_message_by_id(&mut *transaction, private_message.id).await;

    private_message.deleted = true;

    if let Err(e) = delete_private_message_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateMessageDeletion.to_response());
    }

    let recipients = match private_discussion_participation::get_private_discussions_recipients(
        &mut *transaction,
        vec![private_message.discussion_id],
        request_claims.user_id,
    )
    .await
    {
        Ok(r) => r,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    match redis_client.get_multiplexed_async_connection().await {
        Ok(mut con) => {
            let result: Result<(), redis::RedisError> = con
                .publish(
                    "private_message_deleted",
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
                error!("Error: {}", e);
            }

            if let Some(recipient) = recipients.first() {
                let result: Result<(), redis::RedisError> = con
                    .publish(
                        "private_message_deleted",
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
                if let Err(e) = result {
                    error!("Error: {}", e);
                }
            }
        }
        Err(e) => {
            error!("Error: {}", e);
        }
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PrivateMessageResponse {
        code: "PRIVATE_MESSAGE_DELETED".to_string(),
        message: None,
    })
}
