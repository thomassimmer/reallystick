use std::sync::Arc;

use sqlx::{Pool, Postgres};
use tokio::sync::Mutex;
use tracing::{debug, error};
use uuid::Uuid;

use api::{
    core::helpers::{mock_now::now, translation::Translator},
    features::{
        auth::helpers::token::get_user_tokens,
        challenges::helpers::challenge_participation::get_challenge_participants_to_send_reminder_notification,
        habits::helpers::habit_participation::get_habit_participants_to_send_reminder_notification,
        private_discussions::structs::models::users_data::UsersData,
        profile::helpers::profile::get_user_by_id,
    },
};

use crate::features::oauth_fcm::token_manager::TokenManager;

use super::redis_handler::send_push_notification;

pub async fn send_reminder_notifications(
    connection_pool: Pool<Postgres>,
    users_data: UsersData,
    token_manager: Arc<Mutex<TokenManager>>,
    translator: &Translator,
) {
    match get_habit_participants_to_send_reminder_notification(&connection_pool).await {
        Ok(users_concerned) => {
            debug!(
                "Utc now: {} - Users to send a notification to remind a habit: {:?}",
                now().time(),
                users_concerned
            );

            for (user, habit_id, body) in users_concerned {
                let url = format!("/habits/{}", habit_id);

                send_reminder_notification_to_user(
                    user,
                    &users_data,
                    &connection_pool,
                    &token_manager,
                    translator,
                    body.unwrap_or_default(),
                    url,
                )
                .await;
            }
        }
        Err(e) => {
            error!("Error: {}", e);
        }
    }
    match get_challenge_participants_to_send_reminder_notification(&connection_pool).await {
        Ok(users_concerned) => {
            debug!(
                "Utc now: {} - Users to send a notification to remind a challenge: {:?}",
                now().time(),
                users_concerned
            );

            for (user, challenge_id, body) in users_concerned {
                let url = format!("/challenges/{}", challenge_id);

                send_reminder_notification_to_user(
                    user,
                    &users_data,
                    &connection_pool,
                    &token_manager,
                    translator,
                    body.unwrap_or_default(),
                    url,
                )
                .await;
            }
        }
        Err(e) => {
            error!("Error: {}", e);
        }
    }
}

pub async fn send_reminder_notification_to_user(
    user_id: Uuid,
    users_data: &UsersData,
    connection_pool: &Pool<Postgres>,
    token_manager: &Arc<Mutex<TokenManager>>,
    translator: &Translator,
    body: String,
    url: String,
) {
    let user_data = match users_data.get_value_for_key(user_id).await {
        Some(user_data) => user_data,

        None => {
            let user = match get_user_by_id(connection_pool, user_id).await {
                Ok(Some(u)) => u,
                Err(e) => {
                    error!("Error: {}", e);
                    return;
                }
                _ => return,
            };

            let tokens = match get_user_tokens(user_id, connection_pool).await {
                Ok(r) => r,
                Err(e) => {
                    error!("Error: {}", e);
                    return;
                }
            };

            users_data.insert(user, tokens).await
        }
    };

    let title = translator.translate(&user_data.user.locale, "reminder-title", None);

    for (_, token) in user_data.tokens {
        let can_send_a_push_notification = user_data.user.notifications_enabled;

        if can_send_a_push_notification {
            if token.is_mobile == Some(true) && token.browser.is_none() {
                if let Some(fcm_token) = token.fcm_token {
                    send_push_notification(
                        token_manager,
                        fcm_token,
                        title.clone(),
                        body.clone(),
                        Some(url.clone()),
                    )
                    .await;
                }
            }
        }
    }
}
