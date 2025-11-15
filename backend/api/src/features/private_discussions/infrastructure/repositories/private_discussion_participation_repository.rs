// PrivateDiscussionParticipationRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::private_discussions::domain::entities::private_discussion_participation::PrivateDiscussionParticipation;
use crate::features::private_discussions::domain::repositories::private_discussion_participation_repository::PrivateDiscussionParticipationRepository;

pub struct PrivateDiscussionParticipationRepositoryImpl {
    pool: PgPool,
}

impl PrivateDiscussionParticipationRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        participation: &PrivateDiscussionParticipation,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO private_discussion_participations (
                id,
                discussion_id,
                user_id,
                color,
                created_at,
                has_blocked
            )
            VALUES ( $1, $2, $3, $4, $5, $6)
            "#,
            participation.id,
            participation.discussion_id,
            participation.user_id,
            participation.color,
            participation.created_at,
            participation.has_blocked
        )
        .execute(executor)
        .await
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        participation: &PrivateDiscussionParticipation,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE private_discussion_participations 
            SET 
                color = $1,
                has_blocked = $2
            WHERE id = $3
            "#,
            participation.color,
            participation.has_blocked,
            participation.id,
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        participation_id: Uuid,
        executor: E,
    ) -> Result<Option<PrivateDiscussionParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PrivateDiscussionParticipation,
            r#"
            SELECT *
            FROM private_discussion_participations
            WHERE id = $1
            "#,
            participation_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_by_user_id_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<Vec<PrivateDiscussionParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PrivateDiscussionParticipation,
            r#"
            SELECT *
            FROM private_discussion_participations
            WHERE user_id = $1
            "#,
            user_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_by_user_and_discussion_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        discussion_id: Uuid,
        executor: E,
    ) -> Result<Option<PrivateDiscussionParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PrivateDiscussionParticipation,
            r#"
            SELECT *
            FROM private_discussion_participations
            WHERE user_id = $1 AND discussion_id = $2
            "#,
            user_id,
            discussion_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_by_discussion_id_with_executor<'a, E>(
        &self,
        discussion_id: Uuid,
        executor: E,
    ) -> Result<Vec<PrivateDiscussionParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PrivateDiscussionParticipation,
            r#"
            SELECT *
            FROM private_discussion_participations
            WHERE discussion_id = $1
            "#,
            discussion_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_recipients_with_executor<'a, E>(
        &self,
        discussion_ids: Vec<Uuid>,
        user_id: Uuid,
        executor: E,
    ) -> Result<Vec<PrivateDiscussionParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            PrivateDiscussionParticipation,
            r#"
            SELECT *
            FROM private_discussion_participations
            WHERE user_id != $1 AND discussion_id = ANY($2)
            "#,
            user_id,
            &discussion_ids
        )
        .fetch_all(executor)
        .await
    }
}

#[async_trait]
impl PrivateDiscussionParticipationRepository for PrivateDiscussionParticipationRepositoryImpl {
    async fn create(&self, participation: &PrivateDiscussionParticipation) -> Result<(), String> {
        self.create_with_executor(participation, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update(&self, participation: &PrivateDiscussionParticipation) -> Result<(), String> {
        self.update_with_executor(participation, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(
        &self,
        participation_id: Uuid,
    ) -> Result<Option<PrivateDiscussionParticipation>, String> {
        self.get_by_id_with_executor(participation_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_user_id(
        &self,
        user_id: Uuid,
    ) -> Result<Vec<PrivateDiscussionParticipation>, String> {
        self.get_by_user_id_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_user_and_discussion(
        &self,
        user_id: Uuid,
        discussion_id: Uuid,
    ) -> Result<Option<PrivateDiscussionParticipation>, String> {
        self.get_by_user_and_discussion_with_executor(user_id, discussion_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_discussion_id(
        &self,
        discussion_id: Uuid,
    ) -> Result<Vec<PrivateDiscussionParticipation>, String> {
        self.get_by_discussion_id_with_executor(discussion_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_recipients(
        &self,
        discussion_ids: Vec<Uuid>,
        user_id: Uuid,
    ) -> Result<Vec<PrivateDiscussionParticipation>, String> {
        self.get_recipients_with_executor(discussion_ids, user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }
}
