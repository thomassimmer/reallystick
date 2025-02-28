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

pub async fn get_challenge_participation_for_user_and_challenge<'a, E>(
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
        WHERE user_id = $1 AND challenge_id = $2
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
            timezone = $5
        WHERE id = $6
        "#,
        challenge_participation.color,
        challenge_participation.start_date,
        challenge_participation.notifications_reminder_enabled,
        challenge_participation.reminder_time,
        challenge_participation.timezone,
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
            timezone
        )
        VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9 )
        "#,
        challenge_participation.id,
        challenge_participation.user_id,
        challenge_participation.challenge_id,
        challenge_participation.color,
        challenge_participation.start_date,
        challenge_participation.created_at,
        challenge_participation.notifications_reminder_enabled,
        challenge_participation.reminder_time,
        challenge_participation.timezone,
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
