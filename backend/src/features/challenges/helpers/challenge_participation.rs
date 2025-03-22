use sqlx::{postgres::PgQueryResult, Executor, Postgres};
use uuid::Uuid;

use crate::features::challenges::structs::models::challenge_participation::ChallengeParticipation;

pub async fn get_challenge_participation_by_id<'a, E>(
    executor: E,
    challenge_participation_id: Uuid,
) -> Result<Option<ChallengeParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeParticipation,
        r#"
        SELECT *
        from challenge_participations
        WHERE id = $1
        "#,
        challenge_participation_id,
    )
    .fetch_optional(executor)
    .await
}

pub async fn get_challenge_participations_for_user<'a, E>(
    executor: E,
    user_id: Uuid,
) -> Result<Vec<ChallengeParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeParticipation,
        r#"
        SELECT *
        from challenge_participations
        WHERE user_id = $1
        "#,
        user_id
    )
    .fetch_all(executor)
    .await
}

pub async fn get_ongoing_challenge_participation_for_user_and_challenge<'a, E>(
    executor: E,
    user_id: Uuid,
    challenge_id: Uuid,
) -> Result<Option<ChallengeParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeParticipation,
        r#"
        SELECT *
        from challenge_participations
        WHERE
            user_id = $1
            AND challenge_id = $2
            AND finished = false
        "#,
        user_id,
        challenge_id
    )
    .fetch_optional(executor)
    .await
}

pub async fn get_challenge_participations_for_challenge<'a, E>(
    executor: E,
    challenge_id: Uuid,
) -> Result<Vec<ChallengeParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeParticipation,
        r#"
        SELECT *
        from challenge_participations
        WHERE challenge_id = $1
        "#,
        challenge_id
    )
    .fetch_all(executor)
    .await
}

pub async fn update_challenge_participation<'a, E>(
    executor: E,
    challenge_participation: &ChallengeParticipation,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeParticipation,
        r#"
        UPDATE challenge_participations
        SET
            color = $1,
            start_date = $2,
            notifications_reminder_enabled = $3,
            reminder_time = $4,
            reminder_body = $5,
            finished = $6
        WHERE id = $7
        "#,
        challenge_participation.color,
        challenge_participation.start_date,
        challenge_participation.notifications_reminder_enabled,
        challenge_participation.reminder_time,
        challenge_participation.reminder_body,
        challenge_participation.finished,
        challenge_participation.id
    )
    .execute(executor)
    .await
}

pub async fn create_challenge_participation<'a, E>(
    executor: E,
    challenge_participation: &ChallengeParticipation,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeParticipation,
        r#"
        INSERT INTO challenge_participations (
            id,
            user_id,
            challenge_id,
            color,
            start_date,
            created_at,
            notifications_reminder_enabled,
            reminder_time,
            reminder_body,
            finished
        )
        VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10 )
        "#,
        challenge_participation.id,
        challenge_participation.user_id,
        challenge_participation.challenge_id,
        challenge_participation.color,
        challenge_participation.start_date,
        challenge_participation.created_at,
        challenge_participation.notifications_reminder_enabled,
        challenge_participation.reminder_time,
        challenge_participation.reminder_body,
        challenge_participation.finished
    )
    .execute(executor)
    .await
}

pub async fn delete_challenge_participation_by_id<'a, E>(
    executor: E,
    challenge_participation_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        Challenge,
        r#"
        DELETE
        from challenge_participations
        WHERE id = $1
        "#,
        challenge_participation_id,
    )
    .execute(executor)
    .await
}

pub async fn get_challenge_participation_count<'a, E>(executor: E) -> Result<i64, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    let row = sqlx::query!(
        r#"
        SELECT COUNT(*) as count
        FROM challenge_participations
        "#,
    )
    .fetch_one(executor)
    .await?;

    Ok(row.count.unwrap_or(0))
}

pub async fn get_challenge_participants_to_send_reminder_notification<'a, E>(
    executor: E,
) -> Result<Vec<(Uuid, Uuid, Option<String>)>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    let results = sqlx::query!(
        r#"
        SELECT cp.user_id, cp.challenge_id, cp.reminder_body
        FROM challenge_participations cp
        JOIN users u ON cp.user_id = u.id
        WHERE
            u.timezone IS NOT NULL 
            AND u.timezone <> ''
            AND DATE_TRUNC('minute', NOW() AT TIME ZONE u.timezone)::TIME = DATE_TRUNC('minute', cp.reminder_time)
            AND cp.notifications_reminder_enabled = true
            AND cp.finished = false
        "#,
    )
    .fetch_all(executor)
    .await?;

    Ok(results
        .iter()
        .map(|a| (a.user_id, a.challenge_id, a.reminder_body.clone()))
        .collect())
}
