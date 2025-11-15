// Signup route - uses clean architecture

use std::sync::Arc;

use crate::core::constants::errors::AppError;
use crate::core::helpers::{mock_now::now, translation::Translator};
use crate::core::structs::responses::GenericResponse;
use crate::features::auth::application::dto::requests::UserRegisterRequest;
use crate::features::auth::application::dto::responses::UserSignupResponse;
use crate::features::auth::application::use_cases::generate_tokens::GenerateTokensUseCase;
use crate::features::auth::application::use_cases::signup::SignupUseCase;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::token_service::TokenService;
use crate::features::auth::infrastructure::services::username_service::UsernameService;
use crate::features::private_discussions::{
    application::use_cases::{
        create_private_discussion::CreatePrivateDiscussionUseCase,
        create_private_message::CreatePrivateMessageUseCase,
    },
    domain::entities::{
        private_discussion::PrivateDiscussion,
        private_discussion_participation::PrivateDiscussionParticipation,
        private_message::PrivateMessage,
    },
    infrastructure::repositories::{
        private_discussion_participation_repository::PrivateDiscussionParticipationRepositoryImpl,
        private_discussion_repository::PrivateDiscussionRepositoryImpl,
        private_message_repository::PrivateMessageRepositoryImpl,
    },
};
use crate::features::profile::helpers::device_info::get_user_agent;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json};
use actix_web::{post, HttpRequest, HttpResponse, Responder};
use fluent::FluentArgs;
use redis::Client;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/signup")]
pub async fn register_user(
    req: HttpRequest,
    body: Json<UserRegisterRequest>,
    pool: Data<PgPool>,
    translator: Data<Arc<Translator>>,
    secret: Data<String>,
    redis_client: Data<Client>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let body = body.into_inner();
    let username_lower = body.username.to_lowercase();

    // Validate username
    let username_service = UsernameService::new();
    if let Some(exception) = username_service.validate(&body.username) {
        return HttpResponse::Unauthorized().json(exception.to_response());
    }

    // Create repositories and services
    let pool_clone = pool.get_ref().clone();
    let user_repo = UserRepositoryImpl::new(pool_clone.clone());
    let token_repo = UserTokenRepositoryImpl::new(pool_clone.clone());
    let token_service = TokenService::new(redis_client.clone());

    // Execute signup use case
    let user_repo_for_signup = UserRepositoryImpl::new(pool_clone.clone());
    let signup_use_case = SignupUseCase::new(user_repo_for_signup);
    let new_user = match signup_use_case
        .execute(
            body.username.clone(),
            body.password.clone(),
            body.locale.clone(),
            body.theme.clone(),
            body.timezone.clone(),
            &mut transaction,
        )
        .await
    {
        Ok(user) => user,
        Err(AppError::UserUpdate) => {
            // Username already exists
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::Conflict().json(GenericResponse {
                code: "USER_ALREADY_EXISTS".to_string(),
                message: format!("User with username: {} already exists", username_lower),
            });
        }
        Err(AppError::PasswordTooShort) => {
            // Password validation errors
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::Unauthorized().json(AppError::PasswordTooShort.to_response());
        }
        Err(AppError::PasswordTooWeak) => {
            // Password validation errors
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::Unauthorized().json(AppError::PasswordTooWeak.to_response());
        }
        Err(e) => {
            error!("Error during signup: {:?}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(e.to_response());
        }
    };

    // Update user with keys from request
    let mut user_with_keys = new_user.clone();
    user_with_keys.public_key = Some(body.public_key.clone());
    user_with_keys.private_key_encrypted = Some(body.private_key_encrypted.clone());
    user_with_keys.salt_used_to_derive_key_from_password =
        Some(body.salt_used_to_derive_key_from_password.clone());

    // Update user keys
    if let Err(e) = user_repo
        .update_keys_with_executor(&user_with_keys, &mut *transaction)
        .await
    {
        error!("Error updating user keys: {}", e);
        if let Err(e) = transaction.rollback().await {
            error!("Error rolling back: {}", e);
        }
        return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
    }

    // Generate tokens
    let parsed_device_info = get_user_agent(req).await;
    let generate_tokens_use_case = GenerateTokensUseCase::new(token_repo, token_service);
    let (access_token, refresh_token) = match generate_tokens_use_case
        .execute(
            secret.as_bytes(),
            user_with_keys.clone(),
            parsed_device_info,
            &mut transaction,
        )
        .await
    {
        Ok(tokens) => tokens,
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError()
                .json(AppError::TokenGeneration.to_response());
        }
    };

    // Get reallystick user for welcome message
    let reallystick_user = match user_repo
        .get_by_username_with_executor("reallystick", &mut *transaction)
        .await
    {
        Ok(Some(user)) => user,
        Ok(None) => {
            error!("Error: reallystick user does not exist.");
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::UserNotFound.to_response());
        }
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Create private discussion
    let discussion = PrivateDiscussion {
        id: Uuid::new_v4(),
        created_at: now(),
    };

    // Create participations
    let discussion_participation_for_user = PrivateDiscussionParticipation {
        id: Uuid::new_v4(),
        user_id: user_with_keys.id,
        discussion_id: discussion.id,
        color: "blue".to_string(),
        created_at: now(),
        has_blocked: false,
    };

    let discussion_participation_for_reallystick_user = PrivateDiscussionParticipation {
        id: Uuid::new_v4(),
        user_id: reallystick_user.id,
        discussion_id: discussion.id,
        color: "blue".to_string(),
        created_at: now(),
        has_blocked: false,
    };

    // Create repositories and use case for private discussion
    let pool_clone2 = pool.get_ref().clone();
    let discussion_repo = PrivateDiscussionRepositoryImpl::new(pool_clone2.clone());
    let participation_repo = PrivateDiscussionParticipationRepositoryImpl::new(pool_clone2.clone());

    let create_discussion_use_case =
        CreatePrivateDiscussionUseCase::new(discussion_repo, participation_repo);
    if let Err(e) = create_discussion_use_case
        .execute(
            &discussion,
            &discussion_participation_for_user,
            &discussion_participation_for_reallystick_user,
            &mut transaction,
        )
        .await
    {
        error!("Error: {:?}", e);
        if let Err(e) = transaction.rollback().await {
            error!("Error rolling back: {}", e);
        }
        return HttpResponse::InternalServerError().json(e.to_response());
    }

    // Create welcome message
    let mut args = FluentArgs::new();
    args.set("username", user_with_keys.username.clone());

    let private_message = PrivateMessage {
        id: Uuid::new_v4(),
        discussion_id: discussion.id,
        creator: reallystick_user.id,
        created_at: now(),
        updated_at: None,
        content: translator.translate(
            &user_with_keys.locale,
            "welcome-private-message",
            Some(args),
        ),
        creator_encrypted_session_key: "NOT_ENCRYPTED".to_string(),
        recipient_encrypted_session_key: "NOT_ENCRYPTED".to_string(),
        deleted: false,
        seen: false,
    };

    // Create repositories and use case for private message
    let pool_clone3 = pool.get_ref().clone();
    let message_repo = PrivateMessageRepositoryImpl::new(pool_clone3.clone());
    let discussion_repo2 = PrivateDiscussionRepositoryImpl::new(pool_clone3.clone());

    let create_message_use_case = CreatePrivateMessageUseCase::new(message_repo, discussion_repo2);
    if let Err(e) = create_message_use_case
        .execute(&private_message, &mut transaction)
        .await
    {
        error!("Error: {:?}", e);
        if let Err(e) = transaction.rollback().await {
            error!("Error rolling back: {}", e);
        }
        return HttpResponse::InternalServerError().json(e.to_response());
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Created().json(UserSignupResponse {
        code: "USER_SIGNED_UP".to_string(),
        access_token,
        refresh_token,
    })
}
