use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        private_discussions::{
            helpers::{
                private_discussion_participation::get_private_discussion_participations_by_discussion,
                private_message::{self, get_private_message_by_id},
            },
            structs::{
                models::private_message::ChannelsData,
                requests::private_message::UpdatePrivateMessageParams,
                responses::private_message::PrivateMessageResponse,
            },
        },
    },
};
use actix_web::{
    get,
    web::{Data, Path, ReqData},
    HttpResponse, Responder,
};
use serde_json::json;
use sqlx::PgPool;

#[get("/mark-as-seen/{message_id}")]
pub async fn mark_message_as_seen(
    pool: Data<PgPool>,
    params: Path<UpdatePrivateMessageParams>,
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

    //  Fetch participations
    // Fetch conversation
    let recipient_participation = match get_private_discussion_participations_by_discussion(
        &mut transaction,
        private_message.discussion_id,
    )
    .await
    {
        Ok(r) => r
            .into_iter()
            .filter(|p| p.user_id != private_message.creator)
            .next(),
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Check request user is recipient
    if recipient_participation.is_none()
        || recipient_participation.clone().unwrap().user_id != request_claims.user_id
    {
        return HttpResponse::Unauthorized()
            .json(AppError::PrivateMessageUpdateNotDoneByCreator.to_response());
    }

    private_message.seen = true;

    let update_private_message_result =
        private_message::mark_private_message_as_seen(&mut transaction, &private_message).await;

    if let Err(e) = update_private_message_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateMessageUpdate.to_response());
    }

    if let Some(p) = recipient_participation {
        if let Some(mut session) = channels_data.get_value_for_key(p.user_id).await {
            let _ = session
                .text(json!(private_message.to_private_message_data()).to_string())
                .await;
        }
    }

    if let Some(mut session) = channels_data
        .get_value_for_key(request_claims.user_id)
        .await
    {
        let _ = session
            .text(json!(private_message.to_private_message_data()).to_string())
            .await;
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
