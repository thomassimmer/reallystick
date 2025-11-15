// PrivateMessageRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use chrono::{DateTime, Utc};
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::private_discussions::domain::entities::private_message::PrivateMessage;
use crate::features::private_discussions::domain::repositories::private_message_repository::PrivateMessageRepository;

pub struct PrivateMessageRepositoryImpl {
    pool: PgPool,
}

impl PrivateMessageRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        message: &PrivateMessage,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO private_messages (
                id,
                discussion_id,
                creator,
                created_at,
                updated_at,
                content,
                creator_encrypted_session_key,
                recipient_encrypted_session_key,
                deleted,
                seen
            )
            VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            "#,
            message.id,
            message.discussion_id,
            message.creator,
            message.created_at,
            message.updated_at,
            message.content,
            message.creator_encrypted_session_key,
            message.recipient_encrypted_session_key,
            message.deleted,
            message.seen,
        )
        .execute(executor)
        .await
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        message: &PrivateMessage,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE private_messages
            SET updated_at = $1, content = $2, seen = $3
            WHERE id = $4
            "#,
            message.updated_at,
            message.content,
            message.seen,
            message.id,
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        message_id: Uuid,
        executor: E,
    ) -> Result<Option<PrivateMessage>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PrivateMessage,
            r#"
            SELECT *
            FROM private_messages
            WHERE id = $1
            "#,
            message_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_by_discussion_id_with_executor<'a, E>(
        &self,
        discussion_id: Uuid,
        before_date: Option<DateTime<Utc>>,
        executor: E,
    ) -> Result<Vec<PrivateMessage>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        if let Some(before) = before_date {
            sqlx::query_as!(
                PrivateMessage,
                r#"
                SELECT *
                FROM private_messages
                WHERE discussion_id = $1
                  AND created_at < $2
                ORDER BY created_at DESC
                LIMIT 50
                "#,
                discussion_id,
                before
            )
            .fetch_all(executor)
            .await
        } else {
            sqlx::query_as!(
                PrivateMessage,
                r#"
                SELECT *
                FROM private_messages
                WHERE discussion_id = $1
                ORDER BY created_at DESC
                LIMIT 50
                "#,
                discussion_id
            )
            .fetch_all(executor)
            .await
        }
    }

    pub async fn get_last_messages_for_discussions_with_executor<'a, E>(
        &self,
        discussion_ids: Vec<Uuid>,
        executor: E,
    ) -> Result<Vec<PrivateMessage>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PrivateMessage,
            r#"
            SELECT pm.*
            FROM private_messages pm
            WHERE pm.id IN (
                SELECT DISTINCT ON (discussion_id) id
                FROM private_messages
                WHERE discussion_id = ANY($1)
                ORDER BY discussion_id, created_at DESC
            )
            "#,
            &discussion_ids,
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_unseen_count_for_discussions_with_executor<'a, E>(
        &self,
        discussion_ids: Vec<Uuid>,
        user_id: Uuid,
        executor: E,
    ) -> Result<Vec<(Uuid, i64)>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        let results = sqlx::query!(
            r#"
            SELECT pm.discussion_id, COUNT(*) AS unseen_count
            FROM private_messages pm
            WHERE 
                pm.discussion_id = ANY($1)
                AND pm.creator != $2
                AND pm.seen = false
            GROUP BY pm.discussion_id
            "#,
            &discussion_ids,
            user_id,
        )
        .fetch_all(executor)
        .await?;

        Ok(results
            .iter()
            .map(|r| (r.discussion_id, r.unseen_count.unwrap_or_default()))
            .collect())
    }

    pub async fn mark_as_seen_with_executor<'a, E>(
        &self,
        discussion_id: Uuid,
        user_id: Uuid,
        before_date: DateTime<Utc>,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE private_messages
            SET seen = true
            WHERE discussion_id = $1
              AND creator != $2
              AND created_at <= $3
              AND seen = false
            "#,
            discussion_id,
            user_id,
            before_date
        )
        .execute(executor)
        .await
    }

    pub async fn delete_with_executor<'a, E>(
        &self,
        message_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE private_messages
            SET deleted = true, content = ''
            WHERE id = $1
            "#,
            message_id
        )
        .execute(executor)
        .await
    }

    pub async fn delete_by_user_id_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE FROM private_messages
            WHERE creator = $1
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
            FROM private_messages
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl PrivateMessageRepository for PrivateMessageRepositoryImpl {
    async fn create(&self, message: &PrivateMessage) -> Result<(), String> {
        self.create_with_executor(message, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update(&self, message: &PrivateMessage) -> Result<(), String> {
        self.update_with_executor(message, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(&self, message_id: Uuid) -> Result<Option<PrivateMessage>, String> {
        self.get_by_id_with_executor(message_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_discussion_id(
        &self,
        discussion_id: Uuid,
        before_date: Option<DateTime<Utc>>,
    ) -> Result<Vec<PrivateMessage>, String> {
        self.get_by_discussion_id_with_executor(discussion_id, before_date, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_last_messages_for_discussions(
        &self,
        discussion_ids: Vec<Uuid>,
    ) -> Result<Vec<PrivateMessage>, String> {
        self.get_last_messages_for_discussions_with_executor(discussion_ids, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_unseen_count_for_discussions(
        &self,
        discussion_ids: Vec<Uuid>,
        user_id: Uuid,
    ) -> Result<Vec<(Uuid, i64)>, String> {
        self.get_unseen_count_for_discussions_with_executor(discussion_ids, user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn mark_as_seen(
        &self,
        discussion_id: Uuid,
        user_id: Uuid,
        before_date: DateTime<Utc>,
    ) -> Result<(), String> {
        self.mark_as_seen_with_executor(discussion_id, user_id, before_date, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete(&self, message_id: Uuid) -> Result<(), String> {
        self.delete_with_executor(message_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String> {
        self.delete_by_user_id_with_executor(user_id, &self.pool)
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
