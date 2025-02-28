use sqlx::{postgres::PgQueryResult, PgConnection};
use uuid::Uuid;

use crate::features::public_discussions::structs::models::public_message::PublicMessage;

pub async fn get_reported_messages(
    conn: &mut PgConnection,
) -> Result<Vec<PublicMessage>, sqlx::Error> {
    sqlx::query_as!(
        PublicMessage,
        r#"
           SELECT pm.*
            FROM public_messages pm
            JOIN public_message_reports pmr ON pm.id = pmr.message_id;
        "#,
    )
    .fetch_all(conn)
    .await
}

pub async fn get_user_reported_messages(
    conn: &mut PgConnection,
    user_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error> {
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
    .fetch_all(conn)
    .await
}

pub async fn get_user_liked_messages(
    conn: &mut PgConnection,
    user_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error> {
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
    .fetch_all(conn)
    .await
}

pub async fn get_user_written_messages(
    conn: &mut PgConnection,
    user_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error> {
    sqlx::query_as!(
        PublicMessage,
        r#"
        SELECT *
        from public_messages
        WHERE creator = $1
        "#,
        user_id,
    )
    .fetch_all(conn)
    .await
}

pub async fn get_replies(
    conn: &mut PgConnection,
    message_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error> {
    sqlx::query_as!(
        PublicMessage,
        r#"
        SELECT *
        from public_messages
        WHERE replies_to = $1
        "#,
        message_id,
    )
    .fetch_all(conn)
    .await
}

pub async fn get_first_public_messages_of_challenge(
    conn: &mut PgConnection,
    challenge_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error> {
    sqlx::query_as!(
        PublicMessage,
        r#"
        SELECT *
        from public_messages
        WHERE challenge_id = $1 and replies_to is null and deleted_by_admin = false and deleted_by_creator = false
        "#,
        challenge_id,
    )
    .fetch_all(conn)
    .await
}

pub async fn get_first_public_messages_of_habit(
    conn: &mut PgConnection,
    habit_id: Uuid,
) -> Result<Vec<PublicMessage>, sqlx::Error> {
    sqlx::query_as!(
        PublicMessage,
        r#"
        SELECT *
        from public_messages
        WHERE habit_id = $1 and replies_to is null and deleted_by_admin = false and deleted_by_creator = false
        "#,
        habit_id,
    )
    .fetch_all(conn)
    .await
}

pub async fn get_public_message_by_id(
    conn: &mut PgConnection,
    id: Uuid,
) -> Result<Option<PublicMessage>, sqlx::Error> {
    sqlx::query_as!(
        PublicMessage,
        r#"
        SELECT *
        from public_messages
        WHERE id = $1
        "#,
        id,
    )
    .fetch_optional(conn)
    .await
}

pub async fn delete_public_message(
    conn: &mut PgConnection,
    public_message: &PublicMessage,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        PublicMessage,
        r#"
        UPDATE public_messages
        SET deleted_by_admin = $1, deleted_by_creator = $2
        WHERE id = $3
        "#,
        public_message.deleted_by_admin,
        public_message.deleted_by_creator,
        public_message.id,
    )
    .execute(conn)
    .await
}

pub async fn create_public_message(
    conn: &mut PgConnection,
    public_message: &PublicMessage,
) -> Result<PgQueryResult, sqlx::Error> {
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
    .execute(conn)
    .await
}

pub async fn update_public_message(
    conn: &mut PgConnection,
    public_message: &PublicMessage,
) -> Result<PgQueryResult, sqlx::Error> {
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
    .execute(conn)
    .await
}

pub async fn update_public_message_like_count(
    conn: &mut PgConnection,
    public_message: &PublicMessage,
) -> Result<PgQueryResult, sqlx::Error> {
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
    .execute(conn)
    .await
}

pub async fn update_public_message_reply_count(
    conn: &mut PgConnection,
    public_message: &PublicMessage,
) -> Result<PgQueryResult, sqlx::Error> {
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
    .execute(conn)
    .await
}
