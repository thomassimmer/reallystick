use std::sync::Arc;

use redis::Client;
use serde_json::{json, Value};
use sqlx::{Pool, Postgres};
use tokio::sync::Mutex;
use tracing::info;

use crate::{
    core::structs::redis_messages::{
        NotificationEvent, UserRemovedEvent, UserTokenRemovedEvent, UserTokenUpdatedEvent,
        UserUpdatedEvent,
    },
    features::{
        auth::helpers::token::get_user_tokens,
        oauth_fcm::{
            fcm::{send_fcm_message, FcmNotification},
            token_manager::TokenManager,
        },
        private_discussions::structs::models::{
            channels_data::ChannelsData, users_data::UsersData,
        },
        profile::helpers::profile::get_user_by_id,
    },
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
    pub_sub.subscribe("user_removed").unwrap();
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

    println!("Listening for notifications...");

    while let Ok(msg) = pub_sub.get_message() {
        let payload: String = msg.get_payload().unwrap();
        let msg_type = msg.get_channel_name();

        if msg_type == "user_updated" {
            handle_user_update(&users_data, payload).await;
        } else if msg_type == "user_removed" {
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
    match serde_json::from_str::<UserUpdatedEvent>(&payload) {
        Ok(event) => {
            users_data.update_user(event.user).await;
        }
        _ => return,
    }
}

pub async fn handle_user_deletion(users_data: &UsersData, payload: String) {
    match serde_json::from_str::<UserRemovedEvent>(&payload) {
        Ok(event) => {
            users_data.remove_user(event.user_id).await;
        }
        _ => return,
    }
}

pub async fn handle_user_token_update(users_data: &UsersData, payload: String) {
    match serde_json::from_str::<UserTokenUpdatedEvent>(&payload) {
        Ok(event) => {
            users_data
                .update_user_token(event.user_id, event.token)
                .await;
        }
        _ => return,
    }
}

pub async fn handle_user_token_deletion(users_data: &UsersData, payload: String) {
    match serde_json::from_str::<UserTokenRemovedEvent>(&payload) {
        Ok(event) => {
            users_data
                .remove_user_token(event.user_id, event.token_id)
                .await;
        }
        _ => return,
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
            println!("📩 New message event received: {:?}", event);

            let user_data = match users_data.get_value_for_key(event.recipient).await {
                Some(user_data) => user_data,

                None => {
                    let mut transaction = match connection_pool.begin().await {
                        Ok(t) => t,
                        Err(e) => {
                            eprintln!("Error: {}", e);
                            return;
                        }
                    };

                    let user = match get_user_by_id(&mut transaction, event.recipient).await {
                        Ok(Some(u)) => u,
                        Err(e) => {
                            eprintln!("Error: {}", e);
                            return;
                        }
                        _ => return,
                    };

                    let tokens = match get_user_tokens(event.recipient, &mut transaction).await {
                        Ok(r) => r,
                        Err(e) => {
                            eprintln!("Error: {}", e);
                            return;
                        }
                    };

                    if let Err(e) = transaction.commit().await {
                        eprintln!("Error: {}", e);
                    }

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
                            "{} has {} active sockets.",
                            user_data.user.username,
                            sessions.len()
                        );
                        
                        for (session_uuid, session) in sessions.iter_mut() {
                            let json = json!(
                                {
                                    "type": msg_type,
                                    "data": event.data
                                }
                            );

                            if let Err(e) = session.text(json.to_string()).await {
                                eprintln!("Error: {}", e);
                                channels_data
                                    .remove_key(event.recipient, token_id, *session_uuid)
                                    .await;
                            }

                            println!(
                                "Message sent succesffully to {} on socket {}",
                                user_data.user.username, session_uuid
                            );
                        }
                    }
                    None => {
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
                            if can_send_a_push_notification {
                                if token.is_mobile == Some(true) && token.browser.is_none() {
                                    if let Some(fcm_token) = token.fcm_token {
                                        send_push_notification(
                                            token_manager.clone(),
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
        }
        Err(e) => {
            eprintln!("❌ Failed to deserialize message: {}", e);
        }
    }
}

pub async fn send_push_notification(
    token_manager: Arc<Mutex<TokenManager>>,
    fcm_token: String,
    title: String,
    body: String,
    url: Option<String>,
) {
    let notification = FcmNotification { title, body };

    let payload = match url {
        Some(url) => Some(json!({
            "deeplink": url
        })),
        None => None::<Value>,
    };

    send_fcm_message(
        &fcm_token,
        Some(notification),
        payload,
        &token_manager,
        "reallystick-d807d",
    )
    .await
    .unwrap();
}
