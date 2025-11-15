use crate::{
    core::constants::errors::AppError,
    features::public_discussions::{
        application::dto::{
            requests::public_message::GetPublicMessageParams,
            responses::public_message::PublicMessageResponse,
        },
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

#[get("/{message_id}")]
pub async fn get_message(
    pool: Data<PgPool>,
    params: Path<GetPublicMessageParams>,
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
    let message = match message_repo
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

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PublicMessageResponse {
        code: "PUBLIC_MESSAGE_FETCHED".to_string(),
        message: Some(message.to_public_message_data()),
    })
}
