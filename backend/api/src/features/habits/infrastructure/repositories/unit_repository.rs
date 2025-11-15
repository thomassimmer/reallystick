// UnitRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::habits::domain::entities::unit::Unit;
use crate::features::habits::domain::repositories::unit_repository::UnitRepository;

pub struct UnitRepositoryImpl {
    pool: PgPool,
}

impl UnitRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        unit: &Unit,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO units (id, short_name, long_name, created_at)
            VALUES ( $1, $2, $3, $4 )
            "#,
            unit.id,
            unit.short_name,
            unit.long_name,
            unit.created_at
        )
        .execute(executor)
        .await
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        unit: &Unit,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE units
            SET 
                short_name = $1,
                long_name = $2
            WHERE id = $3
            "#,
            unit.short_name,
            unit.long_name,
            unit.id,
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        unit_id: Uuid,
        executor: E,
    ) -> Result<Option<Unit>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            Unit,
            r#"
            SELECT *
            FROM units
            WHERE id = $1
            "#,
            unit_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_all_with_executor<'a, E>(&self, executor: E) -> Result<Vec<Unit>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            Unit,
            r#"
            SELECT *
            FROM units
            "#
        )
        .fetch_all(executor)
        .await
    }

    pub async fn delete_with_executor<'a, E>(
        &self,
        unit_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE
            FROM units
            WHERE id = $1
            "#,
            unit_id,
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
            FROM units
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl UnitRepository for UnitRepositoryImpl {
    async fn create(&self, unit: &Unit) -> Result<(), String> {
        self.create_with_executor(unit, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update(&self, unit: &Unit) -> Result<(), String> {
        self.update_with_executor(unit, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(&self, id: Uuid) -> Result<Option<Unit>, String> {
        let unit = self
            .get_by_id_with_executor(id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(unit)
    }

    async fn get_all(&self) -> Result<Vec<Unit>, String> {
        let units = self
            .get_all_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(units)
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
