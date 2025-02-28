use sqlx::{postgres::PgQueryResult, PgConnection};
use uuid::Uuid;

use crate::features::habits::structs::models::habit_daily_tracking::HabitDailyTracking;

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
    let result = row.map(|row| HabitDailyTracking {
        id: row.id,
        user_id: row.user_id,
        habit_id: row.habit_id,
        datetime: row.datetime,
        created_at: row.created_at,
        quantity_per_set: row.quantity_per_set,
        quantity_of_set: row.quantity_of_set,
        unit_id: row.unit_id,
    });

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
            datetime: row.datetime,
            created_at: row.created_at,
            quantity_per_set: row.quantity_per_set,
            quantity_of_set: row.quantity_of_set,
            unit_id: row.unit_id,
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
        SET
            datetime = $1,
            quantity_per_set = $2,
            quantity_of_set = $3,
            unit_id = $4
        WHERE id = $5
        "#,
        habit_daily_tracking.datetime,
        habit_daily_tracking.quantity_per_set,
        habit_daily_tracking.quantity_of_set,
        habit_daily_tracking.unit_id,
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
            datetime,
            created_at,
            quantity_per_set,
            quantity_of_set,
            unit_id
        )
        VALUES ( $1, $2, $3, $4, $5, $6, $7, $8 )
        "#,
        habit_daily_tracking.id,
        habit_daily_tracking.user_id,
        habit_daily_tracking.habit_id,
        habit_daily_tracking.datetime,
        habit_daily_tracking.created_at,
        habit_daily_tracking.quantity_per_set,
        habit_daily_tracking.quantity_of_set,
        habit_daily_tracking.unit_id,
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

pub async fn replace_daily_tracking_habit(
    conn: &mut PgConnection,
    old_habit_id: Uuid,
    new_habit_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error> {
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
    .execute(conn)
    .await
}
