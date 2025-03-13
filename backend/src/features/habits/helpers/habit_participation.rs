use sqlx::{postgres::PgQueryResult, Executor, Postgres};
use uuid::Uuid;

use crate::features::habits::structs::models::habit_participation::HabitParticipation;

pub async fn get_habit_participation_by_id<'a, E>(
    executor: E,
    habit_participation_id: Uuid,
) -> Result<Option<HabitParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitParticipation,
        r#"
        SELECT *
        from habit_participations
        WHERE id = $1
        "#,
        habit_participation_id,
    )
    .fetch_optional(executor)
    .await
}

pub async fn get_habit_participations_for_user<'a, E>(
    executor: E,
    user_id: Uuid,
) -> Result<Vec<HabitParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitParticipation,
        r#"
        SELECT *
        from habit_participations
        WHERE user_id = $1
        "#,
        user_id
    )
    .fetch_all(executor)
    .await
}

pub async fn get_habit_participation_for_user_and_habit<'a, E>(
    executor: E,
    user_id: Uuid,
    habit_id: Uuid,
) -> Result<Option<HabitParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitParticipation,
        r#"
        SELECT *
        from habit_participations
        WHERE user_id = $1 AND habit_id = $2
        "#,
        user_id,
        habit_id
    )
    .fetch_optional(executor)
    .await
}

pub async fn get_habit_participations_for_habit<'a, E>(
    executor: E,
    habit_id: Uuid,
) -> Result<Vec<HabitParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitParticipation,
        r#"
        SELECT *
        from habit_participations
        WHERE habit_id = $1
        "#,
        habit_id
    )
    .fetch_all(executor)
    .await
}

pub async fn update_habit_participation<'a, E>(
    executor: E,
    habit_participation: &HabitParticipation,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitParticipation,
        r#"
        UPDATE habit_participations
        SET 
            color = $1,
            to_gain = $2,
            notifications_reminder_enabled = $3,
            reminder_time = $4,
            reminder_body = $5
        WHERE id = $6
        "#,
        habit_participation.color,
        habit_participation.to_gain,
        habit_participation.notifications_reminder_enabled,
        habit_participation.reminder_time,
        habit_participation.reminder_body,
        habit_participation.id
    )
    .execute(executor)
    .await
}

pub async fn create_habit_participation<'a, E>(
    executor: E,
    habit_participation: &HabitParticipation,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitParticipation,
        r#"
        INSERT INTO habit_participations (
            id,
            user_id,
            habit_id,
            color,
            to_gain,
            created_at,
            notifications_reminder_enabled,
            reminder_time,
            reminder_body
        )
        VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9 )
        "#,
        habit_participation.id,
        habit_participation.user_id,
        habit_participation.habit_id,
        habit_participation.color,
        habit_participation.to_gain,
        habit_participation.created_at,
        habit_participation.notifications_reminder_enabled,
        habit_participation.reminder_time,
        habit_participation.reminder_body,
    )
    .execute(executor)
    .await
}

pub async fn delete_habit_participation_by_id<'a, E>(
    executor: E,
    habit_participation_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        Habit,
        r#"
        DELETE
        from habit_participations
        WHERE id = $1
        "#,
        habit_participation_id,
    )
    .execute(executor)
    .await
}

pub async fn replace_participation_habit<'a, E>(
    executor: E,
    old_habit_id: Uuid,
    new_habit_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        HabitParticipation,
        r#"
        UPDATE habit_participations
        SET habit_id = $2
        WHERE habit_id = $1
        "#,
        old_habit_id,
        new_habit_id,
    )
    .execute(executor)
    .await
}

pub async fn get_habit_participation_count<'a, E>(executor: E) -> Result<i64, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    let row = sqlx::query!(
        r#"
        SELECT COUNT(*) as count
        FROM habit_participations
        "#,
    )
    .fetch_one(executor)
    .await?;

    Ok(row.count.unwrap_or(0))
}

pub async fn get_habit_participants_to_send_reminder_notification<'a, E>(
    executor: E,
) -> Result<Vec<(Uuid, Uuid, Option<String>)>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    let results = sqlx::query!(
        r#"
        SELECT hp.user_id, hp.habit_id, hp.reminder_body
        FROM habit_participations hp
        JOIN users u ON hp.user_id = u.id
        WHERE 
            u.timezone IS NOT NULL 
            AND u.timezone <> ''
            AND DATE_TRUNC('minute', NOW() AT TIME ZONE u.timezone)::TIME = DATE_TRUNC('minute', hp.reminder_time)
            AND hp.notifications_reminder_enabled = true
        "#,
    )
    .fetch_all(executor)
    .await?;

    Ok(results
        .iter()
        .map(|a| (a.user_id, a.habit_id, a.reminder_body.clone()))
        .collect())
}
