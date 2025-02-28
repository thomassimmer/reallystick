use crate::{
    core::constants::errors::AppError,
    features::public_discussions::{
        helpers::public_message::get_public_message_by_id,
        structs::{
            models::public_message::PublicMessage,
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

#[get("/parents/{message_id}")]
pub async fn get_message_parents(
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
    let mut message = match get_public_message_by_id(&mut transaction, params.message_id).await {
        Ok(r) => match r {
            Some(r) => r,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::PublicMessageNotFound.to_response());
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let mut parents = Vec::<PublicMessage>::new();

    while let Some(replies_to) = message.replies_to {
        let parent = match get_public_message_by_id(&mut transaction, replies_to).await {
            Ok(r) => match r {
                Some(r) => r,
                None => {
                    return HttpResponse::NotFound()
                        .json(AppError::PublicMessageNotFound.to_response());
                }
            },
            Err(e) => {
                eprintln!("Error: {}", e);
                return HttpResponse::InternalServerError()
                    .json(AppError::DatabaseQuery.to_response());
            }
        };
        parents.insert(0, parent.clone());
        message = parent;
    }

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PublicMessagesResponse {
        code: "PUBLIC_MESSAGE_FETCHED".to_string(),
        messages: parents.iter().map(|m| m.to_public_message_data()).collect(),
    })
}
