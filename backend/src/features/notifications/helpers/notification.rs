use actix_web::web::Data;
use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::{postgres::PgQueryResult, Executor, Postgres};
use tracing::error;
use uuid::Uuid;

use crate::{
    core::{helpers::mock_now::now, structs::redis_messages::NotificationEvent},
    features::notifications::structs::models::Notification,
};

pub async fn create_notification<'a, E>(
    executor: E,
    notification: Notification,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query!(
        r#"
        INSERT INTO notifications (
            id,
            user_id,
            created_at,
            title, 
            body,
            url,
            seen
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        "#,
        notification.id,
        notification.user_id,
        notification.created_at,
        notification.title,
        notification.body,
        notification.url,
        notification.seen
    )
    .execute(executor)
    .await
}

pub async fn get_user_notifications<'a, E>(
    executor: E,
    user_id: Uuid,
) -> Result<Vec<Notification>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        Notification,
        r#"
        SELECT *
        FROM notifications
        WHERE user_id = $1
        "#,
        user_id,
    )
    .fetch_all(executor)
    .await
}

pub async fn mark_notification_as_seen<'a, E>(
    executor: E,
    id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query!(
        r#"
        UPDATE notifications
        SET seen = true
        WHERE id = $1
        "#,
        id,
    )
    .execute(executor)
    .await
}

pub async fn delete_notification<'a, E>(executor: E, id: Uuid) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query!(
        r#"
        DELETE
        from notifications
        WHERE id = $1
        "#,
        id,
    )
    .execute(executor)
    .await
}

pub async fn delete_user_notifications<'a, E>(
    executor: E,
    user_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query!(
        r#"
        DELETE
        from notifications
        WHERE user_id = $1
        "#,
        user_id,
    )
    .execute(executor)
    .await
}

pub async fn generate_notification<'a, E>(
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

    match create_notification(executor, notification.clone()).await {
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

pub async fn get_notification_count<'a, E>(executor: E) -> Result<i64, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    let row = sqlx::query!(
        r#"
        SELECT COUNT(*) as count
        FROM notifications
        "#,
    )
    .fetch_one(executor)
    .await?;

    Ok(row.count.unwrap_or(0))
}
