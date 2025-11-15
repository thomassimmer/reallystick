// Get private discussion messages route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_repository::PrivateDiscussionRepositoryImpl;
use crate::features::private_discussions::infrastructure::repositories::private_message_repository::PrivateMessageRepositoryImpl;
use crate::features::private_discussions::application::dto::requests::private_discussion::{
    GetPrivateDiscussionMessagesParams, GetPrivateDiscussionMessagesQuery,
};
use crate::features::private_discussions::application::dto::responses::private_message::PrivateMessagesResponse;
use actix_web::web::{Data, Path, Query};
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/{discussion_id}")]
pub async fn get_private_discussion_messages(
    pool: Data<PgPool>,
    query: Query<GetPrivateDiscussionMessagesQuery>,
    params: Path<GetPrivateDiscussionMessagesParams>,
) -> impl Responder {
    let query = query.into_inner();

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
    let discussion_repo = PrivateDiscussionRepositoryImpl::new(pool_clone.clone());
    let message_repo = PrivateMessageRepositoryImpl::new(pool_clone.clone());

    // Check if discussion exists
    match discussion_repo
        .get_by_id_with_executor(params.discussion_id, &mut *transaction)
        .await
    {
        Ok(Some(_)) => {}
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound()
                .json(AppError::PrivateDiscussionNotFound.to_response());
        }
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    }

    // Get messages
    let messages = match message_repo
        .get_by_discussion_id_with_executor(
            params.discussion_id,
            query.before_date,
            &mut *transaction,
        )
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

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PrivateMessagesResponse {
        code: "PRIVATE_MESSAGE_FETCHED".to_string(),
        messages: messages
            .iter()
            .map(|m| m.to_private_message_data())
            .collect(),
    })
}
