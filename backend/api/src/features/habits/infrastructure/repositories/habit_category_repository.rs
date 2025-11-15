// HabitCategoryRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::habits::domain::entities::habit_category::HabitCategory;
use crate::features::habits::domain::repositories::habit_category_repository::HabitCategoryRepository;

pub struct HabitCategoryRepositoryImpl {
    pool: PgPool,
}

impl HabitCategoryRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        category: &HabitCategory,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO habit_categories (id, name, created_at, icon)
            VALUES ( $1, $2, $3, $4 )
            "#,
            category.id,
            category.name,
            category.created_at,
            category.icon
        )
        .execute(executor)
        .await
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        category: &HabitCategory,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE habit_categories
            SET name = $1, icon = $2
            WHERE id = $3
            "#,
            category.name,
            category.icon,
            category.id
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        category_id: Uuid,
        executor: E,
    ) -> Result<Option<HabitCategory>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            HabitCategory,
            r#"
            SELECT *
            FROM habit_categories
            WHERE id = $1
            "#,
            category_id,
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_all_with_executor<'a, E>(
        &self,
        executor: E,
    ) -> Result<Vec<HabitCategory>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            HabitCategory,
            r#"
            SELECT *
            FROM habit_categories
            "#
        )
        .fetch_all(executor)
        .await
    }

    pub async fn get_by_name_with_executor<'a, E>(
        &self,
        language_code: String,
        habit_category_name: String,
        executor: E,
    ) -> Result<Option<HabitCategory>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            HabitCategory,
            r#"
            SELECT *
            FROM habit_categories
            WHERE name::jsonb ? $1 AND name::jsonb ->> $1 = $2
            "#,
            language_code,
            habit_category_name,
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn delete_with_executor<'a, E>(
        &self,
        category_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE
            FROM habit_categories
            WHERE id = $1
            "#,
            category_id,
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
            FROM habit_categories
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl HabitCategoryRepository for HabitCategoryRepositoryImpl {
    async fn create(&self, category: &HabitCategory) -> Result<(), String> {
        self.create_with_executor(category, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update(&self, category: &HabitCategory) -> Result<(), String> {
        self.update_with_executor(category, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(&self, id: Uuid) -> Result<Option<HabitCategory>, String> {
        let category = self
            .get_by_id_with_executor(id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(category)
    }

    async fn get_all(&self) -> Result<Vec<HabitCategory>, String> {
        let categories = self
            .get_all_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(categories)
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
