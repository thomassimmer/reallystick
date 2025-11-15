// HabitDailyTrackingRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::habits::domain::entities::habit_daily_tracking::HabitDailyTracking;
use crate::features::habits::domain::repositories::habit_daily_tracking_repository::HabitDailyTrackingRepository;

pub struct HabitDailyTrackingRepositoryImpl {
    pool: PgPool,
}

impl HabitDailyTrackingRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        tracking: &HabitDailyTracking,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO habit_daily_trackings (
                id,
                user_id,
                habit_id,
                datetime,
                created_at,
                quantity_per_set,
                quantity_of_set,
                unit_id,
                weight,
                weight_unit_id,
                challenge_daily_tracking
            )
            VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11 )
            "#,
            tracking.id,
            tracking.user_id,
            tracking.habit_id,
            tracking.datetime,
            tracking.created_at,
            tracking.quantity_per_set,
            tracking.quantity_of_set,
            tracking.unit_id,
            tracking.weight,
            tracking.weight_unit_id,
            tracking.challenge_daily_tracking
        )
        .execute(executor)
        .await
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        tracking: &HabitDailyTracking,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE habit_daily_trackings
            SET
                datetime = $1,
                quantity_per_set = $2,
                quantity_of_set = $3,
                unit_id = $4,
                weight = $5,
                weight_unit_id = $6
            WHERE id = $7
            "#,
            tracking.datetime,
            tracking.quantity_per_set,
            tracking.quantity_of_set,
            tracking.unit_id,
            tracking.weight,
            tracking.weight_unit_id,
            tracking.id
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        tracking_id: Uuid,
        executor: E,
    ) -> Result<Option<HabitDailyTracking>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            HabitDailyTracking,
            r#"
            SELECT *
            FROM habit_daily_trackings
            WHERE id = $1
            "#,
            tracking_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_by_user_id_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<Vec<HabitDailyTracking>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            HabitDailyTracking,
            r#"
            SELECT *
            FROM habit_daily_trackings
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
    ) -> Result<Vec<HabitDailyTracking>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            HabitDailyTracking,
            r#"
            SELECT *
            FROM habit_daily_trackings
            WHERE habit_id = $1
            "#,
            habit_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn delete_with_executor<'a, E>(
        &self,
        tracking_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE FROM habit_daily_trackings
            WHERE id = $1
            "#,
            tracking_id
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
            DELETE FROM habit_daily_trackings
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
            FROM habit_daily_trackings
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl HabitDailyTrackingRepository for HabitDailyTrackingRepositoryImpl {
    async fn create(&self, tracking: &HabitDailyTracking) -> Result<(), String> {
        self.create_with_executor(tracking, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update(&self, tracking: &HabitDailyTracking) -> Result<(), String> {
        self.update_with_executor(tracking, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(&self, tracking_id: Uuid) -> Result<Option<HabitDailyTracking>, String> {
        self.get_by_id_with_executor(tracking_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Vec<HabitDailyTracking>, String> {
        self.get_by_user_id_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_habit_id(&self, habit_id: Uuid) -> Result<Vec<HabitDailyTracking>, String> {
        self.get_by_habit_id_with_executor(habit_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn delete(&self, tracking_id: Uuid) -> Result<(), String> {
        self.delete_with_executor(tracking_id, &self.pool)
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
