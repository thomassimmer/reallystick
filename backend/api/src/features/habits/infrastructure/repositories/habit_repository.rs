// HabitRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::habits::domain::entities::habit::Habit;
use crate::features::habits::domain::repositories::habit_repository::HabitRepository;

pub struct HabitRepositoryImpl {
    pool: PgPool,
}

impl HabitRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        habit: &Habit,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO habits (
                id, name, description, reviewed, created_at, icon, category_id, unit_ids
            )
            VALUES ( $1, $2, $3, $4, $5, $6, $7, $8 )
            "#,
            habit.id,
            habit.name,
            habit.description,
            habit.reviewed,
            habit.created_at,
            habit.icon,
            habit.category_id,
            habit.unit_ids
        )
        .execute(executor)
        .await
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        habit: &Habit,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE habits
            SET 
                name = $1,
                description = $2,
                reviewed = $3,
                icon = $4,
                category_id = $5,
                unit_ids = $6
            WHERE id = $7
            "#,
            habit.name,
            habit.description,
            habit.reviewed,
            habit.icon,
            habit.category_id,
            habit.unit_ids,
            habit.id,
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        habit_id: Uuid,
        executor: E,
    ) -> Result<Option<Habit>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            Habit,
            r#"
            SELECT *
            FROM habits
            WHERE id = $1
            "#,
            habit_id,
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_all_with_executor<'a, E>(&self, executor: E) -> Result<Vec<Habit>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            Habit,
            r#"
            SELECT *
            FROM habits
            "#
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_reviewed_and_personal_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<Vec<Habit>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            Habit,
            r#"
            SELECT DISTINCT
                h.id,
                h.name,
                h.category_id,
                h.reviewed,
                h.description,
                h.icon,
                h.created_at,
                h.unit_ids
            FROM habits h
            LEFT JOIN habit_participations hp ON h.id = hp.habit_id
            WHERE h.reviewed = true OR hp.user_id = $1
            "#,
            user_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn delete_with_executor<'a, E>(
        &self,
        habit_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE
            FROM habits
            WHERE id = $1
            "#,
            habit_id,
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
            FROM habits
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl HabitRepository for HabitRepositoryImpl {
    async fn create(&self, habit: &Habit) -> Result<(), String> {
        self.create_with_executor(habit, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update(&self, habit: &Habit) -> Result<(), String> {
        self.update_with_executor(habit, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(&self, id: Uuid) -> Result<Option<Habit>, String> {
        let habit = self
            .get_by_id_with_executor(id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(habit)
    }

    async fn get_all(&self) -> Result<Vec<Habit>, String> {
        let habits = self
            .get_all_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(habits)
    }

    async fn get_reviewed_and_personal(&self, user_id: Uuid) -> Result<Vec<Habit>, String> {
        let habits = self
            .get_reviewed_and_personal_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(habits)
    }

    async fn delete(&self, id: Uuid) -> Result<(), String> {
        self.delete_with_executor(id, &self.pool)
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
