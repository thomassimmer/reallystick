use sqlx::{postgres::PgQueryResult, Executor, Postgres};
use uuid::Uuid;

use crate::features::habits::structs::models::habit_daily_tracking::HabitDailyTracking;

pub async fn get_habit_daily_tracking_by_id<'a, E>(
    executor: E,
    habit_daily_tracking_id: Uuid,
) -> Result<Option<HabitDailyTracking>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitDailyTracking,
        r#"
        SELECT *
        from habit_daily_trackings
        WHERE id = $1
        "#,
        habit_daily_tracking_id,
    )
    .fetch_optional(executor)
    .await
}

pub async fn get_habit_daily_trackings_for_user<'a, E>(
    executor: E,
    user_id: Uuid,
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

pub async fn update_habit_daily_tracking<'a, E>(
    executor: E,
    habit_daily_tracking: &HabitDailyTracking,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitDailyTracking,
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
        habit_daily_tracking.datetime,
        habit_daily_tracking.quantity_per_set,
        habit_daily_tracking.quantity_of_set,
        habit_daily_tracking.unit_id,
        habit_daily_tracking.weight,
        habit_daily_tracking.weight_unit_id,
        habit_daily_tracking.id
    )
    .execute(executor)
    .await
}

pub async fn create_habit_daily_tracking<'a, E>(
    executor: E,
    habit_daily_tracking: &HabitDailyTracking,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitDailyTracking,
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
            weight_unit_id
        )
        VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10 )
        "#,
        habit_daily_tracking.id,
        habit_daily_tracking.user_id,
        habit_daily_tracking.habit_id,
        habit_daily_tracking.datetime,
        habit_daily_tracking.created_at,
        habit_daily_tracking.quantity_per_set,
        habit_daily_tracking.quantity_of_set,
        habit_daily_tracking.unit_id,
        habit_daily_tracking.weight,
        habit_daily_tracking.weight_unit_id
    )
    .execute(executor)
    .await
}

pub async fn delete_habit_daily_tracking_by_id<'a, E>(
    executor: E,
    habit_daily_tracking_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitDailyTracking,
        r#"
        DELETE
        from habit_daily_trackings
        WHERE id = $1
        "#,
        habit_daily_tracking_id,
    )
    .execute(executor)
    .await
}

pub async fn replace_daily_tracking_habit<'a, E>(
    executor: E,
    old_habit_id: Uuid,
    new_habit_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitDailyTracking,
        r#"
        UPDATE habit_daily_trackings
        SET habit_id = $2
        WHERE habit_id = $1
        "#,
        old_habit_id,
        new_habit_id,
    )
    .execute(executor)
    .await
}

pub async fn get_habit_daily_tracking_count<'a, E>(executor: E) -> Result<i64, sqlx::Error>
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

pub async fn delete_habit_daily_tracking_for_user<'a, E>(
    executor: E,
    user_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitDailyTracking,
        r#"
        DELETE
        from habit_daily_trackings
        WHERE user_id = $1
        "#,
        user_id,
    )
    .execute(executor)
    .await
}
