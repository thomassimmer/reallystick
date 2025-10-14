use sqlx::{postgres::PgQueryResult, Executor, Postgres};
use uuid::Uuid;

use crate::features::habits::structs::models::habit_category::HabitCategory;

pub async fn get_habit_category_by_id<'a, E>(
    executor: E,
    habit_category_id: Uuid,
) -> Result<Option<HabitCategory>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitCategory,
        r#"
        SELECT *
        from habit_categories
        WHERE id = $1
        "#,
        habit_category_id,
    )
    .fetch_optional(executor)
    .await
}

pub async fn get_habit_category_by_name<'a, E>(
    executor: E,
    language_code: String,
    habit_category_name: String,
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

pub async fn get_habit_categories<'a, E>(executor: E) -> Result<Vec<HabitCategory>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitCategory,
        r#"
        SELECT *
        from habit_categories
        "#,
    )
    .fetch_all(executor)
    .await
}

pub async fn update_habit_category<'a, E>(
    executor: E,
    category: &HabitCategory,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        Habit,
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

pub async fn create_habit_category<'a, E>(
    executor: E,
    habit_category: &HabitCategory,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        Habit,
        r#"
        INSERT INTO habit_categories (
            id,
            name,
            created_at,
            icon
        )
        VALUES ( $1, $2, $3, $4 )
        "#,
        habit_category.id,
        habit_category.name,
        habit_category.created_at,
        habit_category.icon
    )
    .execute(executor)
    .await
}

pub async fn delete_habit_category_by_id<'a, E>(
    executor: E,
    habit_category_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        Habit,
        r#"
        DELETE
        from habit_categories
        WHERE id = $1
        "#,
        habit_category_id,
    )
    .execute(executor)
    .await
}

pub async fn get_habit_category_count<'a, E>(executor: E) -> Result<i64, sqlx::Error>
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
