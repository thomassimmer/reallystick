use std::sync::Arc;

use crate::{
    core::{
        constants::errors::AppError,
        helpers::{mock_now::now, translation::Translator},
    },
    features::{
        auth::structs::models::Claims,
        notifications::helpers::notification::generate_notification,
        profile::structs::models::UserPublicDataCache,
        public_discussions::{
            helpers::{
                public_message::{get_public_message_by_id, update_public_message_like_count},
                public_message_like,
            },
            structs::{
                models::public_message_like::PublicMessageLike,
                requests::public_message_like::PublicMessageLikeCreateRequest,
                responses::public_message_like::PublicMessageLikeResponse,
            },
        },
    },
};
use actix_web::{
    post,
    web::{Data, Json, ReqData},
    HttpResponse, Responder,
};
use fluent::FluentArgs;
use redis::Client;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_public_message_like(
    pool: Data<PgPool>,
    body: Json<PublicMessageLikeCreateRequest>,
    redis_client: Data<Client>,
    translator: Data<Arc<Translator>>,
    user_public_data_cache: Data<UserPublicDataCache>,
    request_claims: ReqData<Claims>,
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
    let mut public_message = match get_public_message_by_id(&mut *transaction, body.message_id)
        .await
    {
        Ok(r) => match r {
            Some(r) => r,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::PublicMessageNotFound.to_response());
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let public_message_like = PublicMessageLike {
        id: Uuid::new_v4(),
        message_id: body.message_id,
        user_id: request_claims.user_id,
        created_at: now(),
    };

    let create_public_message_like_result =
        public_message_like::create_public_message_like(&mut *transaction, public_message_like)
            .await;

    if let Err(e) = create_public_message_like_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PublicMessageLikeCreation.to_response());
    }

    public_message.like_count += 1;

    let update_public_message_result =
        update_public_message_like_count(&mut *transaction, &public_message).await;

    if let Err(e) = update_public_message_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PublicMessageUpdate.to_response());
    }

    // If user is not the message's creator
    if request_claims.user_id != public_message.creator {
        if let (Some(person_who_liked), Some(creator)) = (
            user_public_data_cache
                .get_value_for_key_or_insert_it(&request_claims.user_id, &mut *transaction)
                .await,
            user_public_data_cache
                .get_value_for_key_or_insert_it(&public_message.creator, &mut *transaction)
                .await,
        ) {
            let mut args = FluentArgs::new();
            args.set("username", person_who_liked.username);

            let mut url = if let Some(challenge_id) = public_message.challenge_id {
                format!("/challenges/{}", challenge_id)
            } else {
                format!("/habits/{}", public_message.habit_id.unwrap())
            };

            url.push_str(&format!("/threads/{}", public_message.thread_id));

            if let Some(replies_to) = public_message.replies_to {
                url.push_str(&format!("/reply/{}", replies_to));
            }

            generate_notification(
                &mut *transaction,
                public_message.creator,
                &translator.translate(&creator.locale, "user-liked-your-message-title", None),
                &translator.translate(&creator.locale, "user-liked-your-message-body", Some(args)),
                redis_client,
                "public_message_liked",
                Some(url),
            )
            .await;
        }
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PublicMessageLikeResponse {
        code: "PUBLIC_MESSAGE_LIKE_CREATED".to_string(),
    })
}
