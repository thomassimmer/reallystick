// ChallengeParticipationRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::challenges::domain::entities::challenge_participation::ChallengeParticipation;
use crate::features::challenges::domain::repositories::challenge_participation_repository::ChallengeParticipationRepository;

pub struct ChallengeParticipationRepositoryImpl {
    pool: PgPool,
}

impl ChallengeParticipationRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        participation: &ChallengeParticipation,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO challenge_participations (
                id, user_id, challenge_id, color, start_date, created_at,
                notifications_reminder_enabled, reminder_time, reminder_body, finished
            )
            VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10 )
            "#,
            participation.id,
            participation.user_id,
            participation.challenge_id,
            participation.color,
            participation.start_date,
            participation.created_at,
            participation.notifications_reminder_enabled,
            participation.reminder_time,
            participation.reminder_body,
            participation.finished
        )
        .execute(executor)
        .await
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        participation: &ChallengeParticipation,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE challenge_participations
            SET
                color = $1,
                start_date = $2,
                notifications_reminder_enabled = $3,
                reminder_time = $4,
                reminder_body = $5,
                finished = $6
            WHERE id = $7
            "#,
            participation.color,
            participation.start_date,
            participation.notifications_reminder_enabled,
            participation.reminder_time,
            participation.reminder_body,
            participation.finished,
            participation.id
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        participation_id: Uuid,
        executor: E,
    ) -> Result<Option<ChallengeParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            ChallengeParticipation,
            r#"
            SELECT *
            FROM challenge_participations
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
    ) -> Result<Vec<ChallengeParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            ChallengeParticipation,
            r#"
            SELECT *
            FROM challenge_participations
            WHERE user_id = $1
            "#,
            user_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_by_challenge_id_with_executor<'a, E>(
        &self,
        challenge_id: Uuid,
        executor: E,
    ) -> Result<Vec<ChallengeParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            ChallengeParticipation,
            r#"
            SELECT *
            FROM challenge_participations
            WHERE challenge_id = $1
            "#,
            challenge_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_ongoing_by_user_and_challenge_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        challenge_id: Uuid,
        executor: E,
    ) -> Result<Option<ChallengeParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            ChallengeParticipation,
            r#"
            SELECT *
            FROM challenge_participations
            WHERE user_id = $1 AND challenge_id = $2 AND finished = false
            "#,
            user_id,
            challenge_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn delete_with_executor<'a, E>(
        &self,
        participation_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE FROM challenge_participations
            WHERE id = $1
            "#,
            participation_id
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
            DELETE FROM challenge_participations
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
            FROM challenge_participations
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }

    pub async fn get_participants_to_send_reminder_notification_with_executor<'a, E>(
        &self,
        executor: E,
    ) -> Result<Vec<(Uuid, Uuid, Option<String>)>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        let results = sqlx::query!(
            r#"
            SELECT cp.user_id, cp.challenge_id, cp.reminder_body
            FROM challenge_participations cp
            JOIN users u ON cp.user_id = u.id
            WHERE
                u.timezone IS NOT NULL 
                AND u.timezone <> ''
                AND DATE_TRUNC('minute', NOW() AT TIME ZONE u.timezone)::TIME = DATE_TRUNC('minute', cp.reminder_time)
                AND cp.notifications_reminder_enabled = true
                AND cp.finished = false
            "#,
        )
        .fetch_all(executor)
        .await?;

        Ok(results
            .iter()
            .map(|a| (a.user_id, a.challenge_id, a.reminder_body.clone()))
            .collect())
    }
}

#[async_trait]
impl ChallengeParticipationRepository for ChallengeParticipationRepositoryImpl {
    async fn create(&self, participation: &ChallengeParticipation) -> Result<(), String> {
        self.create_with_executor(participation, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update(&self, participation: &ChallengeParticipation) -> Result<(), String> {
        self.update_with_executor(participation, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(
        &self,
        participation_id: Uuid,
    ) -> Result<Option<ChallengeParticipation>, String> {
        self.get_by_id_with_executor(participation_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Vec<ChallengeParticipation>, String> {
        self.get_by_user_id_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_challenge_id(
        &self,
        challenge_id: Uuid,
    ) -> Result<Vec<ChallengeParticipation>, String> {
        self.get_by_challenge_id_with_executor(challenge_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_ongoing_by_user_and_challenge(
        &self,
        user_id: Uuid,
        challenge_id: Uuid,
    ) -> Result<Option<ChallengeParticipation>, String> {
        self.get_ongoing_by_user_and_challenge_with_executor(user_id, challenge_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn delete(&self, participation_id: Uuid) -> Result<(), String> {
        self.delete_with_executor(participation_id, &self.pool)
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

    async fn get_participants_to_send_reminder_notification(
        &self,
    ) -> Result<Vec<(Uuid, Uuid, Option<String>)>, String> {
        self.get_participants_to_send_reminder_notification_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())
    }
}
