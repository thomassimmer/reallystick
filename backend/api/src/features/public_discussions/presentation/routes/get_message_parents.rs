use crate::{
    core::constants::errors::AppError,
    features::public_discussions::{
        application::dto::{
            requests::public_message::GetPublicMessageRepliesParams,
            responses::public_message::PublicMessagesResponse,
        },
        domain::entities::public_message::PublicMessage,
        infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl,
    },
};
use actix_web::{
    get,
    web::{Data, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[get("/parents/{message_id}")]
pub async fn get_message_parents(
    pool: Data<PgPool>,
    params: Path<GetPublicMessageRepliesParams>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repository
    let pool_clone = pool.get_ref().clone();
    let message_repo = PublicMessageRepositoryImpl::new(pool_clone);

    // Check if message exists
    let mut message = match message_repo
        .get_by_id_with_executor(params.message_id, &mut *transaction)
        .await
    {
        Ok(Some(m)) => m,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::PublicMessageNotFound.to_response());
        }
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let mut parents = Vec::<PublicMessage>::new();

    while let Some(replies_to) = message.replies_to {
        let parent = match message_repo
            .get_by_id_with_executor(replies_to, &mut *transaction)
            .await
        {
            Ok(Some(p)) => p,
            Ok(None) => {
                if let Err(e) = transaction.rollback().await {
                    error!("Error rolling back: {}", e);
                }
                return HttpResponse::NotFound()
                    .json(AppError::PublicMessageNotFound.to_response());
            }
            Err(e) => {
                error!("Error: {}", e);
                if let Err(e) = transaction.rollback().await {
                    error!("Error rolling back: {}", e);
                }
                return HttpResponse::InternalServerError()
                    .json(AppError::DatabaseQuery.to_response());
            }
        };
        parents.insert(0, parent.clone());
        message = parent;
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PublicMessagesResponse {
        code: "PUBLIC_MESSAGE_FETCHED".to_string(),
        messages: parents.iter().map(|m| m.to_public_message_data()).collect(),
    })
}
