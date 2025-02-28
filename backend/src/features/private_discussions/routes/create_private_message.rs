use crate::{
    core::{constants::errors::AppError, helpers::mock_now::now},
    features::{
        auth::structs::models::Claims,
        private_discussions::{
            helpers::{
                private_discussion::get_private_discussion_by_id, private_discussion_participation,
                private_message,
            },
            structs::{
                models::private_message::{
                    ChannelsData, PrivateMessage, PRIVATE_MESSAGE_CONTENT_MAX_LENGTH,
                },
                requests::private_message::PrivateMessageCreateRequest,
                responses::private_message::PrivateMessageResponse,
            },
        },
    },
};
use actix_web::{
    post,
    web::{Data, Json, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use uuid::Uuid;

#[post("/")]
pub async fn create_private_message(
    pool: Data<PgPool>,
    body: Json<PrivateMessageCreateRequest>,
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

    // Check if discussion exists
    match get_private_discussion_by_id(&mut transaction, body.discussion_id).await {
        Ok(r) => {
            if r.is_none() {
                return HttpResponse::NotFound()
                    .json(AppError::PrivateDiscussionNotFound.to_response());
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Check content size
    if body.content.len() > PRIVATE_MESSAGE_CONTENT_MAX_LENGTH {
        return HttpResponse::BadRequest()
            .json(AppError::PrivateMessageContentTooLong.to_response());
    } else if body.content.is_empty() {
        return HttpResponse::BadRequest().json(AppError::PrivateMessageContentEmpty.to_response());
    }

    let private_message = PrivateMessage {
        id: Uuid::new_v4(),
        discussion_id: body.discussion_id,
        creator: request_claims.user_id,
        created_at: now(),
        updated_at: None,
        content: body.content.to_owned(),
        creator_encrypted_session_key: body.creator_encrypted_session_key.to_owned(),
        recipient_encrypted_session_key: body.recipient_encrypted_session_key.to_owned(),
        deleted: false,
        seen: false,
    };

    let create_private_message_result =
        private_message::create_private_message(&mut transaction, &private_message).await;

    if let Err(e) = create_private_message_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateMessageCreation.to_response());
    }

    let recipients = match private_discussion_participation::get_private_discussions_recipients(
        &mut transaction,
        vec![body.discussion_id],
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
        code: "PRIVATE_MESSAGE_CREATED".to_string(),
        message: Some(private_message.to_private_message_data()),
    })
}
