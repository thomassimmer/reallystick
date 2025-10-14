use crate::{
    core::{constants::errors::AppError, helpers::mock_now::now},
    features::public_discussions::{
        helpers::public_message::{self, get_public_message_by_id},
        structs::{
            models::public_message::PUBLIC_MESSAGE_CONTENT_MAX_LENGTH,
            requests::public_message::{PublicMessageUpdateRequest, UpdatePublicMessageParams},
            responses::public_message::PublicMessageResponse,
        },
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[put("/{message_id}")]
pub async fn update_public_message(
    pool: Data<PgPool>,
    params: Path<UpdatePublicMessageParams>,
    body: Json<PublicMessageUpdateRequest>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Check if message exists
    let mut public_message = match get_public_message_by_id(&mut *transaction, params.message_id)
        .await
    {
        Ok(r) => match r {
            Some(r) => r,
            None => {
                return HttpResponse::NotFound().json(AppError::PublicMessageNotFound.to_response())
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Check content size
    if body.content.len() > PUBLIC_MESSAGE_CONTENT_MAX_LENGTH {
        return HttpResponse::BadRequest()
            .json(AppError::PublicMessageContentTooLong.to_response());
    } else if body.content.is_empty() {
        return HttpResponse::BadRequest().json(AppError::PublicMessageContentEmpty.to_response());
    }

    public_message.content = body.content.to_owned();
    public_message.updated_at = Some(now());

    let update_public_message_result =
        public_message::update_public_message(&mut *transaction, &public_message).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match update_public_message_result {
        Ok(_) => HttpResponse::Ok().json(PublicMessageResponse {
            code: "PUBLIC_MESSAGE_UPDATED".to_string(),
            message: Some(public_message.to_public_message_data()),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::PublicMessageUpdate.to_response())
        }
    }
}
