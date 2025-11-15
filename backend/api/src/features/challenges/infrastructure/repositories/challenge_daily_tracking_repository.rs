// ChallengeDailyTrackingRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::challenges::domain::entities::challenge_daily_tracking::ChallengeDailyTracking;
use crate::features::challenges::domain::repositories::challenge_daily_tracking_repository::ChallengeDailyTrackingRepository;

pub struct ChallengeDailyTrackingRepositoryImpl {
    pool: PgPool,
}

impl ChallengeDailyTrackingRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        tracking_id: Uuid,
        executor: E,
    ) -> Result<Option<ChallengeDailyTracking>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            ChallengeDailyTracking,
            r#"
            SELECT *
            FROM challenge_daily_trackings
            WHERE id = $1
            "#,
            tracking_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_by_challenge_id_with_executor<'a, E>(
        &self,
        challenge_id: Uuid,
        executor: E,
    ) -> Result<Vec<ChallengeDailyTracking>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            ChallengeDailyTracking,
            r#"
            SELECT *
            FROM challenge_daily_trackings
            WHERE challenge_id = $1
            "#,
            challenge_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_by_challenge_ids_with_executor<'a, E>(
        &self,
        challenge_ids: Vec<Uuid>,
        executor: E,
    ) -> Result<Vec<ChallengeDailyTracking>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            ChallengeDailyTracking,
            r#"
            SELECT *
            FROM challenge_daily_trackings
            WHERE challenge_id = ANY($1)
            "#,
            &challenge_ids
        )
        .fetch_all(executor)
        .await
    }

    pub async fn create_with_executor<'a, E>(
        &self,
        tracking: &ChallengeDailyTracking,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO challenge_daily_trackings (
                id, habit_id, challenge_id, day_of_program, created_at,
                quantity_per_set, quantity_of_set, unit_id, weight, weight_unit_id,
                note, order_in_day
            )
            VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12 )
            "#,
            tracking.id,
            tracking.habit_id,
            tracking.challenge_id,
            tracking.day_of_program,
            tracking.created_at,
            tracking.quantity_per_set,
            tracking.quantity_of_set,
            tracking.unit_id,
            tracking.weight,
            tracking.weight_unit_id,
            tracking.note,
            tracking.order_in_day
        )
        .execute(executor)
        .await
    }

    pub async fn create_batch_with_executor<'a, E>(
        &self,
        trackings: &[ChallengeDailyTracking],
        executor: E,
    ) -> Result<(), sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        if trackings.is_empty() {
            return Ok(());
        }

        let mut ids = Vec::with_capacity(trackings.len());
        let mut habit_ids = Vec::with_capacity(trackings.len());
        let mut challenge_ids = Vec::with_capacity(trackings.len());
        let mut days_of_program = Vec::with_capacity(trackings.len());
        let mut created_ats = Vec::with_capacity(trackings.len());
        let mut quantity_per_sets = Vec::with_capacity(trackings.len());
        let mut quantity_of_sets = Vec::with_capacity(trackings.len());
        let mut unit_ids = Vec::with_capacity(trackings.len());
        let mut weights = Vec::with_capacity(trackings.len());
        let mut weight_unit_ids = Vec::with_capacity(trackings.len());
        let mut notes = Vec::with_capacity(trackings.len());
        let mut orders_in_day = Vec::with_capacity(trackings.len());

        for tracking in trackings {
            ids.push(tracking.id);
            habit_ids.push(tracking.habit_id);
            challenge_ids.push(tracking.challenge_id);
            days_of_program.push(tracking.day_of_program);
            created_ats.push(tracking.created_at);
            quantity_per_sets.push(tracking.quantity_per_set);
            quantity_of_sets.push(tracking.quantity_of_set);
            unit_ids.push(tracking.unit_id);
            weights.push(tracking.weight as f64);
            weight_unit_ids.push(tracking.weight_unit_id);
            notes.push(tracking.note.clone());
            orders_in_day.push(tracking.order_in_day);
        }

        sqlx::query!(
            r#"
            INSERT INTO challenge_daily_trackings (
                id, habit_id, challenge_id, day_of_program, created_at,
                quantity_per_set, quantity_of_set, unit_id, weight, weight_unit_id,
                note, order_in_day
            )
            SELECT * FROM UNNEST(
                $1::UUID[],
                $2::UUID[],
                $3::UUID[],
                $4::INT[],
                $5::TIMESTAMPTZ[],
                $6::DOUBLE PRECISION[],
                $7::INT[],
                $8::UUID[],
                $9::FLOAT8[],
                $10::UUID[],
                $11::TEXT[],
                $12::INT[]
            )
            "#,
            &ids,
            &habit_ids,
            &challenge_ids,
            &days_of_program,
            &created_ats,
            &quantity_per_sets,
            &quantity_of_sets,
            &unit_ids,
            &weights,
            &weight_unit_ids,
            &notes as &[Option<String>],
            &orders_in_day,
        )
        .execute(executor)
        .await?;

        Ok(())
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        tracking: &ChallengeDailyTracking,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE challenge_daily_trackings
            SET
                day_of_program = $1,
                quantity_per_set = $2,
                quantity_of_set = $3,
                unit_id = $4,
                weight = $5,
                weight_unit_id = $6,
                note = $7,
                habit_id = $8,
                order_in_day = $9
            WHERE id = $10
            "#,
            tracking.day_of_program,
            tracking.quantity_per_set,
            tracking.quantity_of_set,
            tracking.unit_id,
            tracking.weight,
            tracking.weight_unit_id,
            tracking.note,
            tracking.habit_id,
            tracking.order_in_day,
            tracking.id
        )
        .execute(executor)
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
            DELETE FROM challenge_daily_trackings
            WHERE id = $1
            "#,
            tracking_id
        )
        .execute(executor)
        .await
    }

    pub async fn delete_by_challenge_id_with_executor<'a, E>(
        &self,
        challenge_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE FROM challenge_daily_trackings
            WHERE challenge_id = $1
            "#,
            challenge_id
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
            FROM challenge_daily_trackings
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl ChallengeDailyTrackingRepository for ChallengeDailyTrackingRepositoryImpl {
    async fn get_by_id(&self, tracking_id: Uuid) -> Result<Option<ChallengeDailyTracking>, String> {
        self.get_by_id_with_executor(tracking_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_challenge_id(
        &self,
        challenge_id: Uuid,
    ) -> Result<Vec<ChallengeDailyTracking>, String> {
        self.get_by_challenge_id_with_executor(challenge_id, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn get_by_challenge_ids(
        &self,
        challenge_ids: Vec<Uuid>,
    ) -> Result<Vec<ChallengeDailyTracking>, String> {
        self.get_by_challenge_ids_with_executor(challenge_ids, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn create(&self, tracking: &ChallengeDailyTracking) -> Result<(), String> {
        self.create_with_executor(tracking, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn create_batch(&self, trackings: &[ChallengeDailyTracking]) -> Result<(), String> {
        self.create_batch_with_executor(trackings, &self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn update(&self, tracking: &ChallengeDailyTracking) -> Result<(), String> {
        self.update_with_executor(tracking, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete(&self, tracking_id: Uuid) -> Result<(), String> {
        self.delete_with_executor(tracking_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete_by_challenge_id(&self, challenge_id: Uuid) -> Result<(), String> {
        self.delete_by_challenge_id_with_executor(challenge_id, &self.pool)
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
