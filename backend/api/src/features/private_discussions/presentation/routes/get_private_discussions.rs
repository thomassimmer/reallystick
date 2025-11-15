// Get private discussions route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_participation_repository::PrivateDiscussionParticipationRepositoryImpl;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_repository::PrivateDiscussionRepositoryImpl;
use crate::features::private_discussions::infrastructure::repositories::private_message_repository::PrivateMessageRepositoryImpl;
use crate::features::private_discussions::application::dto::responses::private_discussion::PrivateDiscussionsResponse;
use actix_web::web::{Data, ReqData};
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[get("/")]
pub async fn get_private_discussions(
    pool: Data<PgPool>,
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
    let participation_repo = PrivateDiscussionParticipationRepositoryImpl::new(pool_clone.clone());
    let discussion_repo = PrivateDiscussionRepositoryImpl::new(pool_clone.clone());
    let message_repo = PrivateMessageRepositoryImpl::new(pool_clone.clone());

    // Get user participations
    let discussion_participations = match participation_repo
        .get_by_user_id_with_executor(request_claims.user_id, &mut *transaction)
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

    let discussion_ids: Vec<Uuid> = discussion_participations
        .iter()
        .map(|p| p.discussion_id)
        .collect();

    if discussion_ids.is_empty() {
        if let Err(e) = transaction.commit().await {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseTransaction.to_response());
        }
        return HttpResponse::Ok().json(PrivateDiscussionsResponse {
            code: "PRIVATE_DISCUSSIONS_FETCHED".to_string(),
            discussions: vec![],
        });
    }

    // Get discussions
    let discussions = match discussion_repo
        .get_by_ids_with_executor(discussion_ids.clone(), &mut *transaction)
        .await
    {
        Ok(d) => d,
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Get recipients
    let recipients = match participation_repo
        .get_recipients_with_executor(
            discussion_ids.clone(),
            request_claims.user_id,
            &mut *transaction,
        )
        .await
    {
        Ok(r) => r,
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Get last messages
    let messages = match message_repo
        .get_last_messages_for_discussions_with_executor(discussion_ids.clone(), &mut *transaction)
        .await
    {
        Ok(m) => m,
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Get unseen messages count
    let unseen_messages = match message_repo
        .get_unseen_count_for_discussions_with_executor(
            discussion_ids,
            request_claims.user_id,
            &mut *transaction,
        )
        .await
    {
        Ok(u) => u,
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PrivateDiscussionsResponse {
        code: "PRIVATE_DISCUSSIONS_FETCHED".to_string(),
        discussions: discussions
            .iter()
            .map(|d| {
                let participation = discussion_participations
                    .iter()
                    .find(|p| p.discussion_id == d.id);

                let last_message = messages
                    .clone()
                    .into_iter()
                    .find(|m| m.discussion_id == d.id);

                let recipient = recipients.iter().find(|p| p.discussion_id == d.id);
                let unseen_message_for_this_discussion = unseen_messages
                    .iter()
                    .filter(|p| p.0 == d.id)
                    .map(|p| p.1)
                    .next();

                d.to_private_discussion_data(
                    participation.map(|p| p.color.clone()),
                    participation.map(|p| p.has_blocked),
                    last_message.map(|m| m.to_private_message_data()),
                    recipient
                        .map(|r| r.user_id)
                        .or(Some(request_claims.user_id)),
                    unseen_message_for_this_discussion.unwrap_or_default(),
                )
            })
            .collect(),
    })
}
