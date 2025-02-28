use sqlx::{postgres::PgQueryResult, Executor, Postgres};
use uuid::Uuid;

use crate::features::habits::structs::models::unit::Unit;

pub async fn get_unit_by_id<'a, E>(executor: E, unit_id: Uuid) -> Result<Option<Unit>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        Unit,
        r#"
        SELECT *
        from units
        WHERE id = $1
        "#,
        unit_id
    )
    .fetch_optional(executor)
    .await
}

pub async fn get_units<'a, E>(executor: E) -> Result<Vec<Unit>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        Unit,
        r#"
        SELECT *
        from units
        "#,
    )
    .fetch_all(executor)
    .await
}

pub async fn update_unit<'a, E>(
    executor: E,
    unit: &Unit,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        Unit,
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

pub async fn create_unit<'a, E>(
    executor: E,
    unit: &Unit,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        Unit,
        r#"
        INSERT INTO units (
            id,
            short_name,
            long_name,
            created_at
        )
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

pub async fn delete_unit_by_id<'a, E>(
    executor: E,
    unit_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        Unit,
        r#"
        DELETE
        from units
        WHERE id = $1
        "#,
        unit_id,
    )
    .execute(executor)
    .await
}
