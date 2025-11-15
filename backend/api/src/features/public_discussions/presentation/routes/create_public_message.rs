use std::sync::Arc;

use crate::{
    core::{
        constants::errors::AppError,
        helpers::{mock_now::now, translation::Translator},
    },
    features::{
        auth::domain::entities::Claims,
        challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl,
        habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl,
        notifications::infrastructure::services::notification_service::NotificationService,
        profile::domain::entities::UserPublicDataCache,
        public_discussions::{
            application::dto::{
                requests::public_message::PublicMessageCreateRequest,
                responses::public_message::PublicMessageResponse,
            },
            application::use_cases::create_public_message::CreatePublicMessageUseCase,
            domain::entities::public_message::PublicMessage,
            infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl,
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
pub async fn create_public_message(
    pool: Data<PgPool>,
    body: Json<PublicMessageCreateRequest>,
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
    let new_message_id = Uuid::new_v4();
    let thread_id = body.thread_id.unwrap_or(new_message_id);

    let new_public_message = PublicMessage {
        id: new_message_id,
        habit_id: body.habit_id,
        challenge_id: body.challenge_id,
        creator: request_claims.user_id,
        thread_id,
        replies_to: body.replies_to,
        created_at: now(),
        updated_at: None,
        content: body.content.to_owned(),
        like_count: 0,
        reply_count: 0,
        deleted_by_creator: false,
        deleted_by_admin: false,
        language_code: None,
    };

    // Get parent message for notification (before use case modifies it)
    let parent_message = if let Some(replies_to) = new_public_message.replies_to {
        let pool_clone = pool.get_ref().clone();
        let message_repo = PublicMessageRepositoryImpl::new(pool_clone);
        message_repo
            .get_by_id_with_executor(replies_to, &mut *transaction)
            .await
            .ok()
            .flatten()
    } else {
        None
    };

    // Create repositories and use case
    let pool_clone = pool.get_ref().clone();
    let message_repo = PublicMessageRepositoryImpl::new(pool_clone.clone());
    let habit_repo = HabitRepositoryImpl::new(pool_clone.clone());
    let challenge_repo = ChallengeRepositoryImpl::new(pool_clone.clone());

    let use_case = CreatePublicMessageUseCase::new(message_repo, habit_repo, challenge_repo);
    let result = use_case
        .execute(&new_public_message, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => {
            // Handle notification for replies (use a new transaction since we already committed)
            if let Some(message) = parent_message {
                if request_claims.user_id != message.creator {
                    let mut notif_transaction = match pool.begin().await {
                        Ok(t) => t,
                        Err(_) => {
                            return HttpResponse::Ok().json(PublicMessageResponse {
                                code: "PUBLIC_MESSAGE_CREATED".to_string(),
                                message: Some(new_public_message.to_public_message_data()),
                            });
                        }
                    };

                    if let (Some(person_who_replied), Some(creator)) = (
                        user_public_data_cache
                            .get_value_for_key_or_insert_it(
                                &request_claims.user_id,
                                &mut notif_transaction,
                            )
                            .await,
                        user_public_data_cache
                            .get_value_for_key_or_insert_it(
                                &message.creator,
                                &mut notif_transaction,
                            )
                            .await,
                    ) {
                        let mut args = FluentArgs::new();
                        args.set("username", person_who_replied.username);

                        let mut url = if let Some(challenge_id) = message.challenge_id {
                            format!("/challenges/{}/null", challenge_id)
                        } else {
                            format!("/habits/{}", message.habit_id.unwrap())
                        };

                        url.push_str(&format!("/threads/{}", message.thread_id));

                        if let Some(replies_to) = message.replies_to {
                            url.push_str(&format!("/reply/{}", replies_to));
                        }

                        notification_service
                            .generate_notification(
                                &mut *notif_transaction,
                                message.creator,
                                &translator.translate(
                                    &creator.locale,
                                    "user-replied-to-your-message-title",
                                    None,
                                ),
                                &translator.translate(
                                    &creator.locale,
                                    "user-replied-to-your-message-body",
                                    Some(args),
                                ),
                                redis_client,
                                "public_message_replied",
                                Some(url),
                            )
                            .await;

                        let _ = notif_transaction.commit().await;
                    } else {
                        let _ = notif_transaction.rollback().await;
                    }
                }
            }

            HttpResponse::Ok().json(PublicMessageResponse {
                code: "PUBLIC_MESSAGE_CREATED".to_string(),
                message: Some(new_public_message.to_public_message_data()),
            })
        }
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
