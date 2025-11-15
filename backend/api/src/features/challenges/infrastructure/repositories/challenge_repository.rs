// ChallengeRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::challenges::domain::entities::challenge::Challenge;
use crate::features::challenges::domain::repositories::ChallengeRepository;

pub struct ChallengeRepositoryImpl {
    pool: PgPool,
}

impl ChallengeRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        challenge: &Challenge,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO challenges (
                id, name, description, start_date, icon, created_at, creator, deleted
            )
            VALUES ( $1, $2, $3, $4, $5, $6, $7, $8 )
            "#,
            challenge.id,
            challenge.name,
            challenge.description,
            challenge.start_date,
            challenge.icon,
            challenge.created_at,
            challenge.creator,
            challenge.deleted,
        )
        .execute(executor)
        .await
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        challenge: &Challenge,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE challenges
            SET 
                name = $1,
                description = $2,
                start_date = $3,
                icon = $4,
                deleted = $5
            WHERE id = $6
            "#,
            challenge.name,
            challenge.description,
            challenge.start_date,
            challenge.icon,
            challenge.deleted,
            challenge.id,
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        challenge_id: Uuid,
        executor: E,
    ) -> Result<Option<Challenge>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            Challenge,
            r#"
            SELECT *
            FROM challenges
            WHERE id = $1
            "#,
            challenge_id,
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_all_with_executor<'a, E>(
        &self,
        executor: E,
    ) -> Result<Vec<Challenge>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            Challenge,
            r#"
            SELECT *
            FROM challenges
            "#
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_created_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<Vec<Challenge>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            Challenge,
            r#"
            SELECT *
            FROM challenges
            WHERE creator = $1
            "#,
            user_id,
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_created_and_joined_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<Vec<Challenge>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            Challenge,
            r#"
            SELECT DISTINCT
                c.id,
                c.name,
                c.description,
                c.icon,
                c.created_at,
                c.start_date,
                c.creator,
                c.deleted
            FROM challenges c
            LEFT JOIN challenge_participations cp ON c.id = cp.challenge_id
            WHERE cp.user_id = $1 OR c.creator = $1
            "#,
            user_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn delete_with_executor<'a, E>(
        &self,
        challenge_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE challenges
            SET deleted = true
            WHERE id = $1
            "#,
            challenge_id,
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
            UPDATE challenges
            SET deleted = true, name = '', description = ''
            WHERE creator = $1
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
            FROM challenges
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl ChallengeRepository for ChallengeRepositoryImpl {
    async fn create(&self, challenge: &Challenge) -> Result<(), String> {
        self.create_with_executor(challenge, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update(&self, challenge: &Challenge) -> Result<(), String> {
        self.update_with_executor(challenge, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(&self, id: Uuid) -> Result<Option<Challenge>, String> {
        let challenge = self
            .get_by_id_with_executor(id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(challenge)
    }

    async fn get_all(&self) -> Result<Vec<Challenge>, String> {
        let challenges = self
            .get_all_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(challenges)
    }

    async fn get_created(&self, user_id: Uuid) -> Result<Vec<Challenge>, String> {
        let challenges = self
            .get_created_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(challenges)
    }

    async fn get_created_and_joined(&self, user_id: Uuid) -> Result<Vec<Challenge>, String> {
        let challenges = self
            .get_created_and_joined_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(challenges)
    }

    async fn delete(&self, id: Uuid) -> Result<(), String> {
        self.delete_with_executor(id, &self.pool)
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
