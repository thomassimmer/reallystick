// HabitParticipationRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::habits::domain::entities::habit_participation::HabitParticipation;
use crate::features::habits::domain::repositories::habit_participation_repository::HabitParticipationRepository;

pub struct HabitParticipationRepositoryImpl {
    pool: PgPool,
}

impl HabitParticipationRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        participation: &HabitParticipation,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO habit_participations (
                id,
                user_id,
                habit_id,
                color,
                to_gain,
                created_at,
                notifications_reminder_enabled,
                reminder_time,
                reminder_body
            )
            VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9 )
            "#,
            participation.id,
            participation.user_id,
            participation.habit_id,
            participation.color,
            participation.to_gain,
            participation.created_at,
            participation.notifications_reminder_enabled,
            participation.reminder_time,
            participation.reminder_body,
        )
        .execute(executor)
        .await
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        participation: &HabitParticipation,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE habit_participations
            SET 
                color = $1,
                to_gain = $2,
                notifications_reminder_enabled = $3,
                reminder_time = $4,
                reminder_body = $5
            WHERE id = $6
            "#,
            participation.color,
            participation.to_gain,
            participation.notifications_reminder_enabled,
            participation.reminder_time,
            participation.reminder_body,
            participation.id
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        participation_id: Uuid,
        executor: E,
    ) -> Result<Option<HabitParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            HabitParticipation,
            r#"
            SELECT *
            FROM habit_participations
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
    ) -> Result<Vec<HabitParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            HabitParticipation,
            r#"
            SELECT *
            FROM habit_participations
            WHERE user_id = $1
            "#,
            user_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_by_habit_id_with_executor<'a, E>(
        &self,
        habit_id: Uuid,
        executor: E,
    ) -> Result<Vec<HabitParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            HabitParticipation,
            r#"
            SELECT *
            FROM habit_participations
            WHERE habit_id = $1
            "#,
            habit_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_by_user_and_habit_id_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        habit_id: Uuid,
        executor: E,
    ) -> Result<Option<HabitParticipation>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            HabitParticipation,
            r#"
            SELECT *
            FROM habit_participations
            WHERE user_id = $1 AND habit_id = $2
            "#,
            user_id,
            habit_id
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
            DELETE FROM habit_participations
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
            DELETE FROM habit_participations
            WHERE user_id = $1
            "#,
            user_id
        )
        .execute(executor)
        .await
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
            SELECT hp.user_id, hp.habit_id, hp.reminder_body
            FROM habit_participations hp
            JOIN users u ON hp.user_id = u.id
            WHERE 
                u.timezone IS NOT NULL 
                AND u.timezone <> ''
                AND DATE_TRUNC('minute', NOW() AT TIME ZONE u.timezone)::TIME = DATE_TRUNC('minute', hp.reminder_time)
                AND hp.notifications_reminder_enabled = true
            "#,
        )
        .fetch_all(executor)
        .await?;

        Ok(results
            .iter()
            .map(|a| (a.user_id, a.habit_id, a.reminder_body.clone()))
            .collect())
    }

    pub async fn count_with_executor<'a, E>(&self, executor: E) -> Result<i64, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        let row = sqlx::query!(
            r#"
            SELECT COUNT(*) as count
            FROM habit_participations
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl HabitParticipationRepository for HabitParticipationRepositoryImpl {
    async fn create(&self, participation: &HabitParticipation) -> Result<(), String> {
        self.create_with_executor(participation, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update(&self, participation: &HabitParticipation) -> Result<(), String> {
        self.update_with_executor(participation, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(
        &self,
        participation_id: Uuid,
    ) -> Result<Option<HabitParticipation>, String> {
        self.get_by_id_with_executor(participation_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Vec<HabitParticipation>, String> {
        self.get_by_user_id_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_habit_id(&self, habit_id: Uuid) -> Result<Vec<HabitParticipation>, String> {
        self.get_by_habit_id_with_executor(habit_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_user_and_habit_id(
        &self,
        user_id: Uuid,
        habit_id: Uuid,
    ) -> Result<Option<HabitParticipation>, String> {
        self.get_by_user_and_habit_id_with_executor(user_id, habit_id, &self.pool)
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

    async fn get_participants_to_send_reminder_notification(
        &self,
    ) -> Result<Vec<(Uuid, Uuid, Option<String>)>, String> {
        self.get_participants_to_send_reminder_notification_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn count(&self) -> Result<i64, String> {
        self.count_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())
    }
}
