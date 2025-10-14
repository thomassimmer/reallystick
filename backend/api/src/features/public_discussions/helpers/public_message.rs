use sqlx::{postgres::PgQueryResult, Executor, Postgres};
use uuid::Uuid;

use crate::features::public_discussions::structs::models::public_message::PublicMessage;

pub async fn get_reported_messages<'a, E>(executor: E) -> Result<Vec<PublicMessage>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
           SELECT pm.*
            FROM public_messages pm
            JOIN public_message_reports pmr ON pm.id = pmr.message_id;
        "#,
    )
    .fetch_all(executor)
    .await
}

pub async fn get_user_reported_messages<'a, E>(
    executor: E,
    user_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
           SELECT pm.*
            FROM public_messages pm
            JOIN public_message_reports pmr ON pm.id = pmr.message_id
            WHERE pmr.reporter = $1;
        "#,
        user_id,
    )
    .fetch_all(executor)
    .await
}

pub async fn get_user_liked_messages<'a, E>(
    executor: E,
    user_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        SELECT pm.*
        FROM public_messages pm
        JOIN public_message_likes pml ON pm.id = pml.message_id
        WHERE pml.user_id = $1;
        "#,
        user_id,
    )
    .fetch_all(executor)
    .await
}

pub async fn get_user_written_messages<'a, E>(
    executor: E,
    user_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        SELECT *
        from public_messages
        WHERE creator = $1
        "#,
        user_id,
    )
    .fetch_all(executor)
    .await
}

pub async fn get_replies<'a, E>(
    executor: E,
    message_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        SELECT *
        from public_messages
        WHERE replies_to = $1
        "#,
        message_id,
    )
    .fetch_all(executor)
    .await
}

pub async fn get_first_public_messages_of_challenge<'a, E>(
    executor: E,
    challenge_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        SELECT *
        from public_messages
        WHERE challenge_id = $1 and replies_to is null and deleted_by_admin = false and deleted_by_creator = false
        "#,
        challenge_id,
    )
    .fetch_all(executor)
    .await
}

pub async fn get_first_public_messages_of_habit<'a, E>(
    executor: E,
    habit_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        SELECT *
        from public_messages
        WHERE habit_id = $1 and replies_to is null and deleted_by_admin = false and deleted_by_creator = false
        "#,
        habit_id,
    )
    .fetch_all(executor)
    .await
}

pub async fn get_public_message_by_id<'a, E>(
    executor: E,
    id: Uuid,
) -> Result<Option<PublicMessage>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        SELECT *
        from public_messages
        WHERE id = $1
        "#,
        id,
    )
    .fetch_optional(executor)
    .await
}

pub async fn delete_public_message<'a, E>(
    executor: E,
    public_message: &PublicMessage,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        UPDATE public_messages
        SET
            deleted_by_admin = $1,
            deleted_by_creator = $2,
            content = $3
        WHERE id = $4
        "#,
        public_message.deleted_by_admin,
        public_message.deleted_by_creator,
        "",
        public_message.id,
    )
    .execute(executor)
    .await
}

pub async fn create_public_message<'a, E>(
    executor: E,
    public_message: &PublicMessage,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        INSERT INTO public_messages (
            id,
            habit_id,
            challenge_id,
            creator,
            thread_id,
            replies_to,
            created_at,
            updated_at,
            content,
            like_count,
            deleted_by_creator,
            deleted_by_admin,
            language_code
        )
        VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
        "#,
        public_message.id,
        public_message.habit_id,
        public_message.challenge_id,
        public_message.creator,
        public_message.thread_id,
        public_message.replies_to,
        public_message.created_at,
        public_message.updated_at,
        public_message.content,
        public_message.like_count,
        public_message.deleted_by_creator,
        public_message.deleted_by_admin,
        public_message.language_code
    )
    .execute(executor)
    .await
}

pub async fn update_public_message<'a, E>(
    executor: E,
    public_message: &PublicMessage,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        UPDATE public_messages
        SET updated_at = $1, content = $2
        WHERE id = $3
        "#,
        public_message.updated_at,
        public_message.content,
        public_message.id,
    )
    .execute(executor)
    .await
}

pub async fn update_public_message_like_count<'a, E>(
    executor: E,
    public_message: &PublicMessage,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        UPDATE public_messages
        SET like_count = $1
        WHERE id = $2
        "#,
        public_message.like_count,
        public_message.id,
    )
    .execute(executor)
    .await
}

pub async fn update_public_message_reply_count<'a, E>(
    executor: E,
    public_message: &PublicMessage,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        UPDATE public_messages
        SET reply_count = $1
        WHERE id = $2
        "#,
        public_message.reply_count,
        public_message.id,
    )
    .execute(executor)
    .await
}

pub async fn get_public_message_count<'a, E>(executor: E) -> Result<i64, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    let row = sqlx::query!(
        r#"
        SELECT COUNT(*) as count
        FROM public_messages
        "#,
    )
    .fetch_one(executor)
    .await?;

    Ok(row.count.unwrap_or(0))
}

pub async fn mark_public_messages_as_deleted_for_user<'a, E>(
    executor: E,
    user_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        PublicMessage,
        r#"
        UPDATE public_messages
        SET
            deleted_by_creator = $1,
            content = $2
        WHERE creator = $3
        "#,
        true,
        "",
        user_id,
    )
    .execute(executor)
    .await
}
