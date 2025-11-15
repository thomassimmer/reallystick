// Mark message as seen route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::core::structs::redis_messages::NotificationEvent;
use crate::features::auth::domain::entities::Claims;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_participation_repository::PrivateDiscussionParticipationRepositoryImpl;
use crate::features::private_discussions::infrastructure::repositories::private_message_repository::PrivateMessageRepositoryImpl;
use crate::features::private_discussions::application::dto::requests::private_message::UpdatePrivateMessageParams;
use crate::features::private_discussions::application::dto::responses::private_message::PrivateMessageResponse;
use actix_web::web::{Data, Path, ReqData};
use actix_web::{get, HttpResponse, Responder};
use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;

#[get("/mark-as-seen/{message_id}")]
pub async fn mark_message_as_seen(
    pool: Data<PgPool>,
    params: Path<UpdatePrivateMessageParams>,
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
    let participation_repo = PrivateDiscussionParticipationRepositoryImpl::new(pool_clone.clone());

    // Get message
    let mut private_message = match message_repo
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

    // Get participations to find recipient
    let participations = match participation_repo
        .get_by_discussion_id_with_executor(private_message.discussion_id, &mut *transaction)
        .await
    {
        Ok(p) => p,
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let recipient_participation = participations
        .into_iter()
        .find(|p| p.user_id != private_message.creator);

    // Check if user is recipient
    if recipient_participation.is_none()
        || recipient_participation.clone().unwrap().user_id != request_claims.user_id
    {
        if let Err(e) = transaction.rollback().await {
            error!("Error rolling back: {}", e);
        }
        return HttpResponse::Unauthorized()
            .json(AppError::PrivateMessageUpdateNotDoneByCreator.to_response());
    }

    // Mark as seen
    private_message.seen = true;
    match message_repo
        .update_with_executor(&private_message, &mut *transaction)
        .await
    {
        Ok(_) => {}
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError()
                .json(AppError::PrivateMessageUpdate.to_response());
        }
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    // Publish Redis event
    if let Ok(mut con) = redis_client
        .get_ref()
        .get_multiplexed_async_connection()
        .await
    {
        let _: Result<(), redis::RedisError> = con
            .publish(
                "private_message_marked_as_seen",
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

        let _: Result<(), redis::RedisError> = con
            .publish(
                "private_message_marked_as_seen",
                json!(NotificationEvent {
                    data: json!(private_message.to_private_message_data()).to_string(),
                    recipient: private_message.creator,
                    title: None,
                    body: None,
                    url: None,
                })
                .to_string(),
            )
            .await;
    }

    HttpResponse::Ok().json(PrivateMessageResponse {
        code: "PRIVATE_MESSAGE_UPDATED".to_string(),
        message: Some(private_message.to_private_message_data()),
    })
}
