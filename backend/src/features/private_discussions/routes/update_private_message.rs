use crate::{
    core::{constants::errors::AppError, helpers::mock_now::now},
    features::{
        auth::structs::models::Claims,
        private_discussions::{
            helpers::{
                private_discussion_participation,
                private_message::{self, get_private_message_by_id},
            },
            structs::{
                models::private_message::{ChannelsData, PRIVATE_MESSAGE_CONTENT_MAX_LENGTH},
                requests::private_message::{
                    PrivateMessageUpdateRequest, UpdatePrivateMessageParams,
                },
                responses::private_message::PrivateMessageResponse,
            },
        },
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[put("/{message_id}")]
pub async fn update_private_message(
    pool: Data<PgPool>,
    params: Path<UpdatePrivateMessageParams>,
    body: Json<PrivateMessageUpdateRequest>,
    channels_data: Data<ChannelsData>,
    request_claims: ReqData<Claims>,
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
    let mut private_message = match get_private_message_by_id(&mut transaction, params.message_id)
        .await
    {
        Ok(r) => match r {
            Some(r) => r,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::PrivateMessageNotFound.to_response())
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
            .json(AppError::PrivateMessageUpdateNotDoneByCreator.to_response());
    }

    // Check content size
    if body.content.len() > PRIVATE_MESSAGE_CONTENT_MAX_LENGTH {
        return HttpResponse::BadRequest()
            .json(AppError::PrivateMessageContentTooLong.to_response());
    } else if body.content.is_empty() {
        return HttpResponse::BadRequest().json(AppError::PrivateMessageContentEmpty.to_response());
    }

    private_message.content = body.content.to_owned();
    private_message.updated_at = Some(now());

    let update_private_message_result =
        private_message::update_private_message(&mut transaction, &private_message).await;

    if let Err(e) = update_private_message_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateMessageUpdate.to_response());
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
        code: "PRIVATE_MESSAGE_UPDATED".to_string(),
        message: Some(private_message.to_private_message_data()),
    })
}
