use std::sync::Arc;

use actix_web::{
    post,
    web::{self, Data},
    HttpRequest, HttpResponse, Responder,
};
use argon2::{password_hash::SaltString, Argon2, PasswordHasher};
use fluent::FluentArgs;
use rand::rngs::OsRng;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

use crate::{
    core::{
        constants::errors::AppError,
        helpers::{mock_now::now, translation::Translator},
        structs::responses::GenericResponse,
    },
    features::{
        auth::{
            helpers::{
                password::is_password_valid, token::generate_tokens, username::is_username_valid,
            },
            structs::{requests::UserRegisterRequest, responses::UserSignupResponse},
        },
        private_discussions::{
            helpers::{
                private_discussion,
                private_discussion_participation::create_private_discussion_participation,
                private_message,
            },
            structs::models::{
                private_discussion::PrivateDiscussion,
                private_discussion_participation::PrivateDiscussionParticipation,
                private_message::PrivateMessage,
            },
        },
        profile::{
            helpers::{
                device_info::get_user_agent,
                profile::{create_user, get_user_by_username, get_user_by_username_even_deleted},
            },
            structs::models::User,
        },
    },
};

#[post("/signup")]
pub async fn register_user(
    req: HttpRequest,
    body: web::Json<UserRegisterRequest>,
    pool: Data<PgPool>,
    translator: Data<Arc<Translator>>,
    secret: Data<String>,
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

    // Check if user already exists
    let existing_user = get_user_by_username_even_deleted(&mut *transaction, &username_lower).await;

    match existing_user {
        Ok(existing_user) => {
            if existing_user.is_some() {
                let error_response = GenericResponse {
                    code: "USER_ALREADY_EXISTS".to_string(),
                    message: format!("User with username: {} already exists", username_lower),
                };
                return HttpResponse::Conflict().json(error_response);
            }
        }
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    }

    // Validate username
    if let Some(exception) = is_username_valid(&body.username) {
        return HttpResponse::Unauthorized().json(exception.to_response());
    }

    // Validate password
    if let Some(exception) = is_password_valid(&body.password) {
        return HttpResponse::Unauthorized().json(exception.to_response());
    }

    // Hash the password
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();
    let password_hash = match argon2.hash_password(body.password.as_bytes(), &salt) {
        Ok(hash) => hash.to_string(),
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::PasswordHash.to_response());
        }
    };

    let new_user = User {
        id: Uuid::new_v4(),
        username: username_lower,
        password: password_hash,
        locale: body.locale,
        theme: body.theme,
        timezone: body.timezone,
        is_admin: false,
        otp_verified: false,
        otp_base32: None,
        otp_auth_url: None,
        created_at: now(),
        updated_at: now(),
        deleted_at: None,
        password_is_expired: false,
        has_seen_questions: false,
        age_category: None,
        gender: None,
        continent: None,
        country: None,
        region: None,
        activity: None,
        financial_situation: None,
        lives_in_urban_area: None,
        relationship_status: None,
        level_of_education: None,
        has_children: None,
        public_key: Some(body.public_key.clone()),
        private_key_encrypted: Some(body.private_key_encrypted.clone()),
        salt_used_to_derive_key_from_password: Some(
            body.salt_used_to_derive_key_from_password.clone(),
        ),
        notifications_enabled: true,
        notifications_for_private_messages_enabled: true,
        notifications_for_public_message_liked_enabled: true,
        notifications_for_public_message_replies_enabled: true,
        notifications_user_joined_your_challenge_enabled: true,
        notifications_user_duplicated_your_challenge_enabled: true,
    };

    let insert_result = create_user(&mut *transaction, new_user.clone()).await;

    if let Err(e) = insert_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError().json(GenericResponse {
            code: "USER_INSERT".to_string(),
            message: "Failed to insert user into the database".to_string(),
        });
    }

    let parsed_device_info = get_user_agent(req).await;

    let (access_token, refresh_token) = match generate_tokens(
        secret.as_bytes(),
        new_user.id,
        new_user.is_admin,
        new_user.username.clone(),
        parsed_device_info,
        &mut *transaction,
    )
    .await
    {
        Ok((access_token, refresh_token)) => (access_token, refresh_token),
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::TokenGeneration.to_response());
        }
    };

    let reallystick_user = match get_user_by_username(&mut *transaction, "reallystick").await {
        Ok(Some(user)) => user,
        Ok(None) => {
            error!("Error: reallystick user does not exist.");
            return HttpResponse::InternalServerError().json(AppError::UserNotFound.to_response());
        }
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let discussion = PrivateDiscussion {
        id: Uuid::new_v4(),
        created_at: now(),
    };

    let create_private_discussion_result =
        private_discussion::create_private_discussion(&mut *transaction, &discussion).await;

    if let Err(e) = create_private_discussion_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateDiscussionCreation.to_response());
    }

    let discussion_participation_for_user = PrivateDiscussionParticipation {
        id: Uuid::new_v4(),
        user_id: new_user.id,
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

    let create_discussion_participation_for_user_result = create_private_discussion_participation(
        &mut *transaction,
        &discussion_participation_for_user,
    )
    .await;

    if let Err(e) = create_discussion_participation_for_user_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateDiscussionParticipationCreation.to_response());
    }

    let create_discussion_participation_for_recipient_result =
        create_private_discussion_participation(
            &mut *transaction,
            &discussion_participation_for_reallystick_user,
        )
        .await;

    if let Err(e) = create_discussion_participation_for_recipient_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateDiscussionParticipationCreation.to_response());
    }

    let mut args = FluentArgs::new();
    args.set("username", new_user.username);

    let private_message = PrivateMessage {
        id: Uuid::new_v4(),
        discussion_id: discussion.id,
        creator: reallystick_user.id,
        created_at: now(),
        updated_at: None,
        content: translator.translate(&new_user.locale, "welcome-private-message", Some(args)),
        creator_encrypted_session_key: "NOT_ENCRYPTED".to_string(),
        recipient_encrypted_session_key: "NOT_ENCRYPTED".to_string(),
        deleted: false,
        seen: false,
    };

    let create_private_message_result =
        private_message::create_private_message(&mut *transaction, &private_message).await;

    if let Err(e) = create_private_message_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateMessageCreation.to_response());
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    let json_response = UserSignupResponse {
        code: "USER_SIGNED_UP".to_string(),
        access_token,
        refresh_token,
    };

    HttpResponse::Created().json(json_response)
}
