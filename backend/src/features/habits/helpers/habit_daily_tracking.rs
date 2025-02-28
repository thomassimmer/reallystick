use chrono::Duration;
use sqlx::{
    postgres::{types::PgInterval, PgQueryResult},
    PgConnection,
};
use uuid::Uuid;

use crate::features::habits::{
    helpers::dates::duration_to_pg_interval,
    structs::models::habit_daily_tracking::HabitDailyTracking,
};

pub async fn get_habit_daily_tracking_by_id(
    conn: &mut PgConnection,
    habit_daily_tracking_id: Uuid,
) -> Result<Option<HabitDailyTracking>, sqlx::Error> {
    let row = sqlx::query!(
        r#"
        SELECT *
        from habit_daily_trackings
        WHERE id = $1
        "#,
        habit_daily_tracking_id,
    )
    .fetch_optional(conn)
    .await?;

    // Map raw rows into `HabitDailyTracking`
    let result = match row {
        Some(row) => Some(HabitDailyTracking {
            id: row.id,
            user_id: row.user_id,
            habit_id: row.habit_id,
            day: row.day,
            created_at: row.created_at,
            duration: {
                let pg_interval: Option<PgInterval> = row.duration;
                pg_interval.map(|interval| {
                    Duration::microseconds(interval.microseconds)
                        + Duration::days(interval.days as i64)
                        + Duration::days((interval.months as i64) * 30) // Approximate months as 30 days
                })
            },
            quantity_per_set: row.quantity_per_set,
            quantity_of_set: row.quantity_of_set,
            unit: row.unit,
            reset: row.reset,
        }),
        None => None,
    };
    Ok(result)
}

pub async fn get_habit_daily_trackings_for_user(
    conn: &mut PgConnection,
    user_id: Uuid,
) -> Result<Vec<HabitDailyTracking>, sqlx::Error> {
    let rows = sqlx::query!(
        r#"
        SELECT *
        FROM habit_daily_trackings
        WHERE user_id = $1
        "#,
        user_id
    )
    .fetch_all(conn)
    .await?;

    // Map raw rows into `HabitDailyTracking`
    let result = rows
        .into_iter()
        .map(|row| HabitDailyTracking {
            id: row.id,
            user_id: row.user_id,
            habit_id: row.habit_id,
            day: row.day,
            created_at: row.created_at,
            duration: {
                let pg_interval: Option<PgInterval> = row.duration;
                pg_interval.map(|interval| {
                    Duration::microseconds(interval.microseconds)
                        + Duration::days(interval.days as i64)
                        + Duration::days((interval.months as i64) * 30) // Approximate months as 30 days
                })
            },
            quantity_per_set: row.quantity_per_set,
            quantity_of_set: row.quantity_of_set,
            unit: row.unit,
            reset: row.reset,
        })
        .collect::<Vec<HabitDailyTracking>>();

    Ok(result)
}

pub async fn update_habit_daily_tracking(
    conn: &mut PgConnection,
    habit_daily_tracking: &HabitDailyTracking,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        HabitDailyTracking,
        r#"
        UPDATE habit_daily_trackings
        SET day = $1, duration = $2, quantity_per_set = $3, quantity_of_set = $4, unit = $5, reset = $6
        WHERE id = $7
        "#,
        habit_daily_tracking.day,
        duration_to_pg_interval(habit_daily_tracking.duration),
        habit_daily_tracking.quantity_per_set,
        habit_daily_tracking.quantity_of_set,
        habit_daily_tracking.unit,
        habit_daily_tracking.reset,
        habit_daily_tracking.id
    )
    .execute(conn)
    .await
}

pub async fn create_habit_daily_tracking(
    conn: &mut PgConnection,
    habit_daily_tracking: &HabitDailyTracking,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        HabitDailyTracking,
        r#"
        INSERT INTO habit_daily_trackings (
            id,
            user_id,
            habit_id,
            day,
            created_at,
            duration,
            quantity_per_set,
            quantity_of_set,
            unit,
            reset
        )
        VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10 )
        "#,
        habit_daily_tracking.id,
        habit_daily_tracking.user_id,
        habit_daily_tracking.habit_id,
        habit_daily_tracking.day,
        habit_daily_tracking.created_at,
        duration_to_pg_interval(habit_daily_tracking.duration),
        habit_daily_tracking.quantity_per_set,
        habit_daily_tracking.quantity_of_set,
        habit_daily_tracking.unit,
        habit_daily_tracking.reset
    )
    .execute(conn)
    .await
}

pub async fn delete_habit_daily_tracking_by_id(
    conn: &mut PgConnection,
    habit_daily_tracking_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        HabitDailyTracking,
        r#"
        DELETE
        from habit_daily_trackings
        WHERE id = $1
        "#,
        habit_daily_tracking_id,
    )
    .execute(conn)
    .await
}
