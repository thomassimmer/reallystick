use crate::{
    core::constants::errors::AppError,
    features::private_discussions::{
        helpers::{
            private_discussion::get_private_discussion_by_id,
            private_message::get_messages_for_discussion,
        },
        structs::{
            requests::private_discussion::GetPrivateDiscussionMessagesParams,
            responses::private_message::PrivateMessagesResponse,
        },
    },
};
use actix_web::{
    get,
    web::{Data, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[get("/{discussion_id}")]
pub async fn get_private_discussion_messages(
    pool: Data<PgPool>,
    params: Path<GetPrivateDiscussionMessagesParams>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Check if discussion exists
    match get_private_discussion_by_id(&mut *transaction, params.discussion_id).await {
        Ok(r) => match r {
            Some(r) => r,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::PrivateDiscussionNotFound.to_response());
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let messages = match get_messages_for_discussion(&mut *transaction, params.discussion_id).await
    {
        Ok(r) => r,
        Err(e) => {
            error!("Error: {}", e);
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
