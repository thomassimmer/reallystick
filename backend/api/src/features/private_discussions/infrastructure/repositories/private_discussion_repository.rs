// PrivateDiscussionRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::private_discussions::domain::entities::private_discussion::PrivateDiscussion;
use crate::features::private_discussions::domain::repositories::private_discussion_repository::PrivateDiscussionRepository;

pub struct PrivateDiscussionRepositoryImpl {
    pool: PgPool,
}

impl PrivateDiscussionRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        discussion: &PrivateDiscussion,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO private_discussions (
                id,
                created_at
            )
            VALUES ($1, $2)
            "#,
            discussion.id,
            discussion.created_at,
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        discussion_id: Uuid,
        executor: E,
    ) -> Result<Option<PrivateDiscussion>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PrivateDiscussion,
            r#"
            SELECT *
            FROM private_discussions
            WHERE id = $1
            "#,
            discussion_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_by_users_with_executor<'a, E>(
        &self,
        user1_id: Uuid,
        user2_id: Uuid,
        executor: E,
    ) -> Result<Option<PrivateDiscussion>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PrivateDiscussion,
            r#"
            WITH participants AS (
                SELECT discussion_id
                FROM private_discussion_participations
                WHERE user_id IN ($1, $2)
                GROUP BY discussion_id
                HAVING COUNT(DISTINCT user_id) = 2
            )
            SELECT pd.*
            FROM private_discussions pd
            JOIN participants p ON pd.id = p.discussion_id
            "#,
            user1_id,
            user2_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_by_ids_with_executor<'a, E>(
        &self,
        discussion_ids: Vec<Uuid>,
        executor: E,
    ) -> Result<Vec<PrivateDiscussion>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PrivateDiscussion,
            r#"
            SELECT *
            FROM private_discussions
            WHERE id = ANY($1)
            "#,
            &discussion_ids
        )
        .fetch_all(executor)
        .await
    }

    pub async fn count_with_executor<'a, E>(&self, executor: E) -> Result<i64, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        let row = sqlx::query!(
            r#"
            SELECT COUNT(*) as count
            FROM private_discussions
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl PrivateDiscussionRepository for PrivateDiscussionRepositoryImpl {
    async fn create(&self, discussion: &PrivateDiscussion) -> Result<(), String> {
        self.create_with_executor(discussion, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(&self, discussion_id: Uuid) -> Result<Option<PrivateDiscussion>, String> {
        self.get_by_id_with_executor(discussion_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_users(
        &self,
        user1_id: Uuid,
        user2_id: Uuid,
    ) -> Result<Option<PrivateDiscussion>, String> {
        self.get_by_users_with_executor(user1_id, user2_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_ids(
        &self,
        discussion_ids: Vec<Uuid>,
    ) -> Result<Vec<PrivateDiscussion>, String> {
        self.get_by_ids_with_executor(discussion_ids, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn count(&self) -> Result<i64, String> {
        self.count_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())
    }
}
