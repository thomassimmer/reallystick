// PublicMessageRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::public_discussions::domain::entities::public_message::PublicMessage;
use crate::features::public_discussions::domain::repositories::public_message_repository::PublicMessageRepository;

pub struct PublicMessageRepositoryImpl {
    pool: PgPool,
}

impl PublicMessageRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        message: &PublicMessage,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO public_messages (
                id,
                habit_id,
                challenge_id,
                creator,
                thread_id,
                replies_to,
                created_at,
                updated_at,
                content,
                like_count,
                deleted_by_creator,
                deleted_by_admin,
                language_code
            )
            VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
            "#,
            message.id,
            message.habit_id,
            message.challenge_id,
            message.creator,
            message.thread_id,
            message.replies_to,
            message.created_at,
            message.updated_at,
            message.content,
            message.like_count,
            message.deleted_by_creator,
            message.deleted_by_admin,
            message.language_code
        )
        .execute(executor)
        .await
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        message: &PublicMessage,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE public_messages
            SET updated_at = $1, content = $2
            WHERE id = $3
            "#,
            message.updated_at,
            message.content,
            message.id,
        )
        .execute(executor)
        .await
    }

    pub async fn update_like_count_with_executor<'a, E>(
        &self,
        message: &PublicMessage,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE public_messages
            SET like_count = $1
            WHERE id = $2
            "#,
            message.like_count,
            message.id,
        )
        .execute(executor)
        .await
    }

    pub async fn update_reply_count_with_executor<'a, E>(
        &self,
        message: &PublicMessage,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE public_messages
            SET reply_count = $1
            WHERE id = $2
            "#,
            message.reply_count,
            message.id,
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        message_id: Uuid,
        executor: E,
    ) -> Result<Option<PublicMessage>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PublicMessage,
            r#"
            SELECT *
            FROM public_messages
            WHERE id = $1
            "#,
            message_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_by_habit_id_with_executor<'a, E>(
        &self,
        habit_id: Uuid,
        executor: E,
    ) -> Result<Vec<PublicMessage>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PublicMessage,
            r#"
            SELECT *
            FROM public_messages
            WHERE habit_id = $1 
              AND replies_to IS NULL 
              AND deleted_by_admin = false 
              AND deleted_by_creator = false
            "#,
            habit_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_by_challenge_id_with_executor<'a, E>(
        &self,
        challenge_id: Uuid,
        executor: E,
    ) -> Result<Vec<PublicMessage>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PublicMessage,
            r#"
            SELECT *
            FROM public_messages
            WHERE challenge_id = $1 
              AND replies_to IS NULL 
              AND deleted_by_admin = false 
              AND deleted_by_creator = false
            "#,
            challenge_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_replies_with_executor<'a, E>(
        &self,
        message_id: Uuid,
        executor: E,
    ) -> Result<Vec<PublicMessage>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PublicMessage,
            r#"
            SELECT *
            FROM public_messages
            WHERE replies_to = $1
            "#,
            message_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_by_creator_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<Vec<PublicMessage>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PublicMessage,
            r#"
            SELECT *
            FROM public_messages
            WHERE creator = $1
            "#,
            user_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_reported_with_executor<'a, E>(
        &self,
        executor: E,
    ) -> Result<Vec<PublicMessage>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PublicMessage,
            r#"
            SELECT pm.*
            FROM public_messages pm
            JOIN public_message_reports pmr ON pm.id = pmr.message_id
            "#
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_reported_by_user_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<Vec<PublicMessage>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PublicMessage,
            r#"
            SELECT pm.*
            FROM public_messages pm
            JOIN public_message_reports pmr ON pm.id = pmr.message_id
            WHERE pmr.reporter = $1
            "#,
            user_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn delete_with_executor<'a, E>(
        &self,
        message: &PublicMessage,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE public_messages
            SET
                deleted_by_admin = $1,
                deleted_by_creator = $2,
                content = $3
            WHERE id = $4
            "#,
            message.deleted_by_admin,
            message.deleted_by_creator,
            "",
            message.id,
        )
        .execute(executor)
        .await
    }

    pub async fn mark_as_deleted_for_user_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE public_messages
            SET
                deleted_by_creator = $1,
                content = $2
            WHERE creator = $3
            "#,
            true,
            "",
            user_id,
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
            FROM public_messages
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl PublicMessageRepository for PublicMessageRepositoryImpl {
    async fn create(&self, message: &PublicMessage) -> Result<(), String> {
        self.create_with_executor(message, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update(&self, message: &PublicMessage) -> Result<(), String> {
        self.update_with_executor(message, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update_like_count(&self, message: &PublicMessage) -> Result<(), String> {
        self.update_like_count_with_executor(message, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update_reply_count(&self, message: &PublicMessage) -> Result<(), String> {
        self.update_reply_count_with_executor(message, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(&self, message_id: Uuid) -> Result<Option<PublicMessage>, String> {
        self.get_by_id_with_executor(message_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_habit_id(&self, habit_id: Uuid) -> Result<Vec<PublicMessage>, String> {
        self.get_by_habit_id_with_executor(habit_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_challenge_id(&self, challenge_id: Uuid) -> Result<Vec<PublicMessage>, String> {
        self.get_by_challenge_id_with_executor(challenge_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_replies(&self, message_id: Uuid) -> Result<Vec<PublicMessage>, String> {
        self.get_replies_with_executor(message_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_creator(&self, user_id: Uuid) -> Result<Vec<PublicMessage>, String> {
        self.get_by_creator_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_reported(&self) -> Result<Vec<PublicMessage>, String> {
        self.get_reported_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_reported_by_user(&self, user_id: Uuid) -> Result<Vec<PublicMessage>, String> {
        self.get_reported_by_user_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn delete(&self, message: &PublicMessage) -> Result<(), String> {
        self.delete_with_executor(message, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn mark_as_deleted_for_user(&self, user_id: Uuid) -> Result<(), String> {
        self.mark_as_deleted_for_user_with_executor(user_id, &self.pool)
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
