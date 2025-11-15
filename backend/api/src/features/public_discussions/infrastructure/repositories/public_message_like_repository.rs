// PublicMessageLikeRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::public_discussions::domain::entities::public_message_like::PublicMessageLike;
use crate::features::public_discussions::domain::repositories::public_message_like_repository::PublicMessageLikeRepository;

pub struct PublicMessageLikeRepositoryImpl {
    pool: PgPool,
}

impl PublicMessageLikeRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        like: &PublicMessageLike,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO public_message_likes (
                id,
                user_id,
                message_id,
                created_at
            )
            VALUES ( $1, $2, $3, $4)
            ON CONFLICT (message_id, user_id) DO NOTHING
            "#,
            like.id,
            like.user_id,
            like.message_id,
            like.created_at
        )
        .execute(executor)
        .await
    }

    pub async fn delete_with_executor<'a, E>(
        &self,
        like_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE FROM public_message_likes
            WHERE id = $1
            "#,
            like_id
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_message_and_user_with_executor<'a, E>(
        &self,
        message_id: Uuid,
        user_id: Uuid,
        executor: E,
    ) -> Result<Option<PublicMessageLike>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PublicMessageLike,
            r#"
            SELECT *
            FROM public_message_likes
            WHERE message_id = $1 AND user_id = $2
            "#,
            message_id,
            user_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_messages_by_user_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<
        Vec<crate::features::public_discussions::domain::entities::public_message::PublicMessage>,
        sqlx::Error,
    >
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            crate::features::public_discussions::domain::entities::public_message::PublicMessage,
            r#"
            SELECT pm.*
            FROM public_messages pm
            JOIN public_message_likes pml ON pm.id = pml.message_id
            WHERE pml.user_id = $1
            "#,
            user_id
        )
        .fetch_all(executor)
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
            DELETE FROM public_message_likes
            WHERE user_id = $1
            "#,
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
            FROM public_message_likes
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl PublicMessageLikeRepository for PublicMessageLikeRepositoryImpl {
    async fn create(&self, like: &PublicMessageLike) -> Result<(), String> {
        self.create_with_executor(like, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete(&self, like_id: Uuid) -> Result<(), String> {
        self.delete_with_executor(like_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_message_and_user(
        &self,
        message_id: Uuid,
        user_id: Uuid,
    ) -> Result<Option<PublicMessageLike>, String> {
        self.get_by_message_and_user_with_executor(message_id, user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_messages_by_user(
        &self,
        user_id: Uuid,
    ) -> Result<
        Vec<crate::features::public_discussions::domain::entities::public_message::PublicMessage>,
        String,
    > {
        self.get_messages_by_user_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
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
