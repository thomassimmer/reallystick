use crate::{
    core::constants::errors::AppError,
    features::public_discussions::{
        helpers::public_message::{self, get_public_message_by_id},
        structs::{
            requests::public_message::GetPublicMessageRepliesParams,
            responses::public_message::PublicMessagesResponse,
        },
    },
};
use actix_web::{
    get,
    web::{Data, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/replies/{message_id}")]
pub async fn get_replies(
    pool: Data<PgPool>,
    params: Path<GetPublicMessageRepliesParams>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Check if message exists
    match get_public_message_by_id(&mut transaction, params.message_id).await {
        Ok(r) => {
            if r.is_none() {
                return HttpResponse::NotFound()
                    .json(AppError::PublicMessageNotFound.to_response());
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let get_messages_result =
        public_message::get_replies(&mut transaction, params.message_id).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match get_messages_result {
        Ok(messages) => HttpResponse::Ok().json(PublicMessagesResponse {
            code: "PUBLIC_MESSAGE_FETCHED".to_string(),
            messages: messages
                .iter()
                .map(|m| m.to_public_message_data())
                .collect(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::PublicMessageCreation.to_response())
        }
    }
}
