use std::sync::Arc;

use crate::{
    core::{
        constants::errors::AppError,
        helpers::{mock_now::now, translation::Translator},
    },
    features::{
        auth::domain::entities::Claims,
        notifications::infrastructure::services::notification_service::NotificationService,
        profile::domain::entities::UserPublicDataCache,
        public_discussions::{
            application::dto::{
                requests::public_message_like::PublicMessageLikeCreateRequest,
                responses::public_message_like::PublicMessageLikeResponse,
            },
            application::use_cases::create_public_message_like::CreatePublicMessageLikeUseCase,
            domain::entities::public_message_like::PublicMessageLike,
            infrastructure::repositories::{
                public_message_like_repository::PublicMessageLikeRepositoryImpl,
                public_message_repository::PublicMessageRepositoryImpl,
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
    let notification_service = NotificationService::new(pool.get_ref().clone());
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let body = body.into_inner();

    let public_message_like = PublicMessageLike {
        id: Uuid::new_v4(),
        message_id: body.message_id,
        user_id: request_claims.user_id,
        created_at: now(),
    };

    // Create repositories and use case
    let pool_clone = pool.get_ref().clone();
    let like_repo = PublicMessageLikeRepositoryImpl::new(pool_clone.clone());
    let message_repo = PublicMessageRepositoryImpl::new(pool_clone.clone());

    let use_case = CreatePublicMessageLikeUseCase::new(like_repo, message_repo);
    let result = use_case
        .execute(&public_message_like, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(creator_id) => {
            // Handle notification (use a new transaction since we already committed)
            if request_claims.user_id != creator_id {
                let mut notif_transaction = match pool.begin().await {
                    Ok(t) => t,
                    Err(_) => {
                        return HttpResponse::Ok().json(PublicMessageLikeResponse {
                            code: "PUBLIC_MESSAGE_LIKE_CREATED".to_string(),
                        });
                    }
                };

                // Get message for URL construction
                let pool_clone2 = pool.get_ref().clone();
                let message_repo2 = PublicMessageRepositoryImpl::new(pool_clone2);
                if let Ok(Some(public_message)) = message_repo2
                    .get_by_id_with_executor(body.message_id, &mut *notif_transaction)
                    .await
                {
                    if let (Some(person_who_liked), Some(creator)) = (
                        user_public_data_cache
                            .get_value_for_key_or_insert_it(
                                &request_claims.user_id,
                                &mut notif_transaction,
                            )
                            .await,
                        user_public_data_cache
                            .get_value_for_key_or_insert_it(&creator_id, &mut notif_transaction)
                            .await,
                    ) {
                        let mut args = FluentArgs::new();
                        args.set("username", person_who_liked.username);

                        let mut url = if let Some(challenge_id) = public_message.challenge_id {
                            format!("/challenges/{}/null", challenge_id)
                        } else {
                            format!("/habits/{}", public_message.habit_id.unwrap())
                        };

                        url.push_str(&format!("/threads/{}", public_message.thread_id));

                        if let Some(replies_to) = public_message.replies_to {
                            url.push_str(&format!("/reply/{}", replies_to));
                        }

                        notification_service
                            .generate_notification(
                                &mut *notif_transaction,
                                creator_id,
                                &translator.translate(
                                    &creator.locale,
                                    "user-liked-your-message-title",
                                    None,
                                ),
                                &translator.translate(
                                    &creator.locale,
                                    "user-liked-your-message-body",
                                    Some(args),
                                ),
                                redis_client,
                                "public_message_liked",
                                Some(url),
                            )
                            .await;

                        let _ = notif_transaction.commit().await;
                    } else {
                        let _ = notif_transaction.rollback().await;
                    }
                } else {
                    let _ = notif_transaction.rollback().await;
                }
            }

            HttpResponse::Ok().json(PublicMessageLikeResponse {
                code: "PUBLIC_MESSAGE_LIKE_CREATED".to_string(),
            })
        }
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
