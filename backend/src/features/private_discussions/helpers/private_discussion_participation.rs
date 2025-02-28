use sqlx::{postgres::PgQueryResult, Executor, Postgres};
use uuid::Uuid;

use crate::features::private_discussions::structs::models::private_discussion_participation::PrivateDiscussionParticipation;

pub async fn create_private_discussion_participation<'a, E>(
    executor: E,
    participation: &PrivateDiscussionParticipation,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PrivateDiscussionParticipation,
        r#"
        INSERT INTO private_discussion_participations (
            id,
            discussion_id,
            user_id,
            color,
            created_at,
            has_blocked
        )
        VALUES ( $1, $2, $3, $4, $5, $6);
        "#,
        participation.id,
        participation.discussion_id,
        participation.user_id,
        participation.color,
        participation.created_at,
        participation.has_blocked
    )
    .execute(executor)
    .await
}

pub async fn update_private_discussion_participation<'a, E>(
    executor: E,
    participation: &PrivateDiscussionParticipation,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PrivateDiscussionParticipation,
        r#"
        UPDATE private_discussion_participations 
        SET 
            color = $1,
            has_blocked = $2
        WHERE id = $3;
        "#,
        participation.color,
        participation.has_blocked,
        participation.id,
    )
    .execute(executor)
    .await
}

pub async fn get_private_discussion_participation_by_user_and_discussion<'a, E>(
    executor: E,
    user_id: Uuid,
    discussion_id: Uuid,
) -> Result<Option<PrivateDiscussionParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PrivateDiscussionParticipation,
        r#"
        SELECT *
        FROM private_discussion_participations
        WHERE user_id = $1 and discussion_id = $2;
        "#,
        user_id,
        discussion_id
    )
    .fetch_optional(executor)
    .await
}

pub async fn get_user_private_discussion_participations<'a, E>(
    executor: E,
    user_id: Uuid,
) -> Result<Vec<PrivateDiscussionParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PrivateDiscussionParticipation,
        r#"
        SELECT *
        FROM private_discussion_participations
        WHERE user_id = $1; 
        "#,
        user_id,
    )
    .fetch_all(executor)
    .await
}

pub async fn get_private_discussions_recipients<'a, E>(
    executor: E,
    discussion_ids: Vec<Uuid>,
    user_id: Uuid,
) -> Result<Vec<PrivateDiscussionParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PrivateDiscussionParticipation,
        r#"
        SELECT *
        FROM private_discussion_participations
        WHERE user_id != $1 and discussion_id = ANY($2); 
        "#,
        user_id,
        &discussion_ids,
    )
    .fetch_all(executor)
    .await
}

pub async fn get_private_discussion_participations_by_discussion<'a, E>(
    executor: E,
    discussion_id: Uuid,
) -> Result<Vec<PrivateDiscussionParticipation>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PrivateDiscussionParticipation,
        r#"
        SELECT *
        FROM private_discussion_participations
        WHERE discussion_id = $1;
        "#,
        discussion_id
    )
    .fetch_all(executor)
    .await
}
