// NotificationRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::notifications::domain::entities::Notification;
use crate::features::notifications::domain::repositories::NotificationRepository;

pub struct NotificationRepositoryImpl {
    pool: PgPool,
}

impl NotificationRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        notification: &Notification,
        executor: E,
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

    pub async fn get_by_user_id_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
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
            ORDER BY created_at DESC
            "#,
            user_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        notification_id: Uuid,
        executor: E,
    ) -> Result<Option<Notification>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            Notification,
            r#"
            SELECT *
            FROM notifications
            WHERE id = $1
            "#,
            notification_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn mark_as_seen_with_executor<'a, E>(
        &self,
        notification_id: Uuid,
        executor: E,
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
            notification_id
        )
        .execute(executor)
        .await
    }

    pub async fn delete_with_executor<'a, E>(
        &self,
        notification_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE FROM notifications
            WHERE id = $1
            "#,
            notification_id
        )
        .execute(executor)
        .await
    }

    pub async fn delete_all_by_user_id_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE FROM notifications
            WHERE user_id = $1
            "#,
            user_id
        )
        .execute(executor)
        .await
    }

    pub async fn count_with_executor<'a, E>(&self, executor: E) -> Result<i64, sqlx::Error>
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
}

#[async_trait]
impl NotificationRepository for NotificationRepositoryImpl {
    async fn create(&self, notification: &Notification) -> Result<(), String> {
        self.create_with_executor(notification, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Vec<Notification>, String> {
        self.get_by_user_id_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_id(&self, notification_id: Uuid) -> Result<Option<Notification>, String> {
        self.get_by_id_with_executor(notification_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn mark_as_seen(&self, notification_id: Uuid) -> Result<(), String> {
        self.mark_as_seen_with_executor(notification_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete(&self, notification_id: Uuid) -> Result<(), String> {
        self.delete_with_executor(notification_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete_all_by_user_id(&self, user_id: Uuid) -> Result<(), String> {
        self.delete_all_by_user_id_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn count(&self) -> Result<i64, String> {
        self.count_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())
    }
}
