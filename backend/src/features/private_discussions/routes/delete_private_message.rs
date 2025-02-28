use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        private_discussions::{
            helpers::{
                private_discussion_participation,
                private_message::{self, get_private_message_by_id},
            },
            structs::{
                models::private_message::ChannelsData,
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
use sqlx::PgPool;

#[delete("/")]
pub async fn delete_private_message(
    pool: Data<PgPool>,
    query: Query<DeletePrivateMessageParams>,
    channels_data: Data<ChannelsData>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let params = query.into_inner();

    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Check if message exists
    let private_message = match get_private_message_by_id(&mut transaction, params.message_id).await
    {
        Ok(r) => match r {
            Some(private_message) => private_message,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::PrivateMessageNotFound.to_response());
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // check request user is creator
    if private_message.creator != request_claims.user_id {
        return HttpResponse::Unauthorized()
            .json(AppError::PrivateMessageDeletionNotDoneByCreator.to_response());
    }

    let delete_private_message_result =
        private_message::delete_message_by_id(&mut transaction, private_message.id).await;

    if let Err(e) = delete_private_message_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateMessageDeletion.to_response());
    }

    let recipients = match private_discussion_participation::get_private_discussions_recipients(
        &mut transaction,
        vec![private_message.discussion_id],
        request_claims.user_id,
    )
    .await
    {
        Ok(r) => r,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    if let Some(recipient) = recipients.iter().next() {
        if let Some(tx) = channels_data.get_value_for_key(recipient.user_id).await {
            let _ = tx.send(private_message.to_private_message_data());
        }
    }

    if let Some(tx) = channels_data
        .get_value_for_key(request_claims.user_id)
        .await
    {
        let _ = tx.send(private_message.to_private_message_data());
    }

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PrivateMessageResponse {
        code: "PRIVATE_MESSAGE_DELETED".to_string(),
        message: None,
    })
}
