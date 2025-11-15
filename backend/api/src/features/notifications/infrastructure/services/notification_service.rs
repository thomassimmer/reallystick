// NotificationService - handles notification creation and Redis publishing

use actix_web::web::Data;
use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::{Executor, PgPool, Postgres};
use tracing::error;
use uuid::Uuid;

use crate::core::{helpers::mock_now::now, structs::redis_messages::NotificationEvent};
use crate::features::notifications::domain::entities::Notification;
use crate::features::notifications::infrastructure::repositories::notification_repository::NotificationRepositoryImpl;

pub struct NotificationService {
    repository: NotificationRepositoryImpl,
}

impl NotificationService {
    pub fn new(pool: PgPool) -> Self {
        Self {
            repository: NotificationRepositoryImpl::new(pool),
        }
    }

    pub async fn generate_notification<'a, E>(
        &self,
        executor: E,
        user_id: Uuid,
        title: &str,
        body: &str,
        redis_client: Data<Client>,
        notification_type: &str,
        url: Option<String>,
    ) where
        E: Executor<'a, Database = Postgres>,
    {
        // Create a notification
        let notification = Notification {
            id: Uuid::new_v4(),
            user_id,
            created_at: now(),
            title: title.to_string(),
            body: body.to_string(),
            url: url.clone(),
            seen: false,
        };

        match self
            .repository
            .create_with_executor(&notification, executor)
            .await
        {
            Ok(_) => match redis_client.get_multiplexed_async_connection().await {
                Ok(mut con) => {
                    let result: Result<(), redis::RedisError> = con
                        .publish(
                            notification_type,
                            json!(NotificationEvent {
                                data: json!(notification.to_notification_data()).to_string(),
                                recipient: user_id,
                                title: Some(title.to_string()),
                                body: Some(body.to_string()),
                                url
                            })
                            .to_string(),
                        )
                        .await;
                    if let Err(e) = result {
                        error!("Error: {}", e);
                    }
                }
                Err(e) => {
                    error!("Error: {}", e);
                }
            },
            Err(e) => {
                error!("Error: {}", e);
            }
        }
    }
}
