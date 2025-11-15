use std::sync::Arc;

use redis::Client;
use serde_json::json;
use sqlx::{Pool, Postgres};
use tokio::sync::Mutex;
use tracing::{error, info};

use api::{
    core::structs::redis_messages::{
        NotificationEvent, UserRemovedEvent, UserTokenRemovedEvent, UserTokenUpdatedEvent,
        UserUpdatedEvent,
    },
    features::{
        auth::{
            domain::repositories::UserTokenRepository,
            infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl,
        },
        private_discussions::domain::entities::{
            channels_data::ChannelsData, users_data::UsersData,
        },
        profile::{
            domain::repositories::UserRepository,
            infrastructure::repositories::user_repository::UserRepositoryImpl,
        },
    },
};

use crate::features::oauth_fcm::{
    fcm::{send_fcm_message, FcmNotification},
    token_manager::TokenManager,
};

pub async fn handle_redis_messages(
    redis_client: Client,
    connection_pool: Pool<Postgres>,
    channels_data: ChannelsData,
    users_data: UsersData,
    token_manager: Arc<Mutex<TokenManager>>,
) {
    let mut redis_conn = redis_client.get_connection().unwrap();
    let mut pub_sub = redis_conn.as_pubsub();

    pub_sub.subscribe("user_updated").unwrap();
    pub_sub.subscribe("user_marked_as_deleted").unwrap();
    pub_sub.subscribe("user_deleted").unwrap();
    pub_sub.subscribe("user_token_updated").unwrap();
    pub_sub.subscribe("user_token_removed").unwrap();
    pub_sub.subscribe("private_message_created").unwrap();
    pub_sub.subscribe("private_message_deleted").unwrap();
    pub_sub.subscribe("private_message_marked_as_seen").unwrap();
    pub_sub.subscribe("private_message_updated").unwrap();
    pub_sub.subscribe("public_message_liked").unwrap();
    pub_sub.subscribe("public_message_replied").unwrap();
    pub_sub.subscribe("challenge_joined").unwrap();
    pub_sub.subscribe("challenge_duplicated").unwrap();

    info!("Listening for notifications...");

    while let Ok(msg) = pub_sub.get_message() {
        let payload: String = msg.get_payload().unwrap();
        let msg_type = msg.get_channel_name();

        if msg_type == "user_updated" {
            handle_user_update(&users_data, payload).await;
        } else if msg_type == "user_marked_as_deleted" || msg_type == "user_deleted" {
            handle_user_deletion(&users_data, payload).await;
        } else if msg_type == "user_token_updated" {
            handle_user_token_update(&users_data, payload).await;
        } else if msg_type == "user_token_removed" {
            handle_user_token_deletion(&users_data, payload).await;
        } else {
            handle_notification(
                &connection_pool,
                &channels_data,
                &users_data,
                payload,
                msg_type,
                token_manager.clone(),
            )
            .await;
        }
    }
}

pub async fn handle_user_update(users_data: &UsersData, payload: String) {
    if let Ok(event) = serde_json::from_str::<UserUpdatedEvent>(&payload) {
        users_data.update_user(event.user).await;
    }
}

pub async fn handle_user_deletion(users_data: &UsersData, payload: String) {
    if let Ok(event) = serde_json::from_str::<UserRemovedEvent>(&payload) {
        users_data.remove_user(event.user_id).await;
    }
}

pub async fn handle_user_token_update(users_data: &UsersData, payload: String) {
    if let Ok(event) = serde_json::from_str::<UserTokenUpdatedEvent>(&payload) {
        users_data.update_user_token(event.user, event.token).await;
    }
}

pub async fn handle_user_token_deletion(users_data: &UsersData, payload: String) {
    if let Ok(event) = serde_json::from_str::<UserTokenRemovedEvent>(&payload) {
        users_data
            .remove_user_token(event.user_id, event.token_id)
            .await;
    }
}

pub async fn handle_notification(
    connection_pool: &Pool<Postgres>,
    channels_data: &ChannelsData,
    users_data: &UsersData,
    payload: String,
    msg_type: &str,
    token_manager: Arc<Mutex<TokenManager>>,
) {
    // Try to deserialize the JSON payload into `NewPrivateMessageEvent`
    match serde_json::from_str::<NotificationEvent>(&payload) {
        Ok(event) => {
            info!("📩 New message event received: {:?}", event);

            let user_data = match users_data.get_value_for_key(event.recipient).await {
                Some(user_data) => user_data,

                None => {
                    let user_repo = UserRepositoryImpl::new(connection_pool.clone());
                    let user = match user_repo.get_by_id(event.recipient).await {
                        Ok(Some(u)) => u,
                        Err(e) => {
                            error!("Error: {}", e);
                            return;
                        }
                        _ => return,
                    };

                    let token_repo = UserTokenRepositoryImpl::new(connection_pool.clone());
                    let tokens = match token_repo.get_by_user_id(event.recipient).await {
                        Ok(r) => r,
                        Err(e) => {
                            error!("Error: {}", e);
                            return;
                        }
                    };

                    users_data.insert(user, tokens).await
                }
            };

            for (token_id, token) in user_data.tokens {
                match channels_data
                    .get_value_for_key(event.recipient, token_id)
                    .await
                {
                    Some(mut sessions) => {
                        info!(
                            "{} has {} active sockets for the token {}.",
                            user_data.user.username,
                            sessions.len(),
                            token_id
                        );

                        for (session_uuid, session) in sessions.iter_mut() {
                            let json = json!(
                                {
                                    "type": msg_type,
                                    "data": event.data
                                }
                            );

                            if let Err(e) = session.text(json.to_string()).await {
                                error!("Error: {}", e);
                                channels_data
                                    .remove_key(event.recipient, token_id, *session_uuid)
                                    .await;
                            }

                            info!(
                                "Message sent succesffully to {} on socket {}",
                                user_data.user.username, session_uuid
                            );
                        }
                    }
                    None => {
                        info!(
                            "{} has no active sockets for the token {}.",
                            user_data.user.username, token_id
                        );

                        let can_send_a_push_notification = match msg_type {
                            "challenge_joined" => {
                                user_data.user.notifications_enabled
                                    && user_data
                                        .user
                                        .notifications_user_joined_your_challenge_enabled
                            }
                            "challenge_duplicated" => {
                                user_data.user.notifications_enabled
                                    && user_data
                                        .user
                                        .notifications_user_duplicated_your_challenge_enabled
                            }
                            "private_message_created" => {
                                user_data.user.notifications_enabled
                                    && user_data.user.notifications_for_private_messages_enabled
                            }
                            "public_message_liked" => {
                                user_data.user.notifications_enabled
                                    && user_data
                                        .user
                                        .notifications_for_public_message_liked_enabled
                            }
                            "public_message_replied" => {
                                user_data.user.notifications_enabled
                                    && user_data
                                        .user
                                        .notifications_for_public_message_replies_enabled
                            }
                            _ => false,
                        };

                        if let (Some(title), Some(body)) = (event.title.clone(), event.body.clone())
                        {
                            if can_send_a_push_notification
                                && token.is_mobile == Some(true)
                                && token.browser.is_none()
                            {
                                if let Some(fcm_token) = token.fcm_token {
                                    send_push_notification(
                                        &token_manager,
                                        fcm_token,
                                        title,
                                        body,
                                        event.url.clone(),
                                    )
                                    .await;
                                }
                            }
                        }
                    }
                }
            }
        }
        Err(e) => {
            error!("❌ Failed to deserialize message: {}", e);
        }
    }
}

pub async fn send_push_notification(
    token_manager: &Arc<Mutex<TokenManager>>,
    fcm_token: String,
    title: String,
    body: String,
    url: Option<String>,
) {
    let notification = FcmNotification { title, body };

    let payload = url.map(|url| {
        json!({
            "deeplink": url
        })
    });

    if let Err(e) = send_fcm_message(
        &fcm_token,
        Some(notification),
        payload,
        token_manager,
        "reallystick-d807d", // TODO: Set as environment variable
    )
    .await
    {
        error!("Error: {}", e);
    }
}
