use sqlx::{postgres::PgQueryResult, Executor, Postgres};
use uuid::Uuid;

use crate::features::public_discussions::structs::models::public_message_like::PublicMessageLike;

pub async fn create_public_message_like<'a, E>(
    executor: E,
    public_message_like: PublicMessageLike,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessageLike,
        r#"
        INSERT INTO public_message_likes (
            id,
            user_id,
            message_id,
            created_at
        )
        VALUES ( $1, $2, $3, $4)
        ON CONFLICT (message_id, user_id) DO NOTHING;
        "#,
        public_message_like.id,
        public_message_like.user_id,
        public_message_like.message_id,
        public_message_like.created_at
    )
    .execute(executor)
    .await
}

pub async fn delete_public_message_like<'a, E>(
    executor: E,
    id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessageLike,
        r#"
        DELETE FROM public_message_likes
        WHERE id = $1
        "#,
        id,
    )
    .execute(executor)
    .await
}

pub async fn get_public_message_like_by_message_id_and_user_id<'a, E>(
    executor: E,
    message_id: Uuid,
    user_id: Uuid,
) -> Result<Option<PublicMessageLike>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessageLike,
        r#"
        SELECT *
        from public_message_likes
        WHERE message_id = $1 and user_id = $2
        "#,
        message_id,
        user_id,
    )
    .fetch_optional(executor)
    .await
}

pub async fn get_public_message_like_count<'a, E>(executor: E) -> Result<i64, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    let row = sqlx::query!(
        r#"
        SELECT COUNT(*) as count
        FROM public_message_likes
        "#,
    )
    .fetch_one(executor)
    .await?;

    Ok(row.count.unwrap_or(0))
}
