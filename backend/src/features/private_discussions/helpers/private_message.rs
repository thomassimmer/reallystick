use sqlx::{postgres::PgQueryResult, PgConnection};
use uuid::Uuid;

use crate::features::private_discussions::structs::models::private_message::PrivateMessage;

pub async fn get_private_message_by_id(
    conn: &mut PgConnection,
    message_id: Uuid,
) -> Result<Option<PrivateMessage>, sqlx::Error> {
    sqlx::query_as!(
        PrivateMessage,
        r#"
        SELECT *
        FROM private_messages
        WHERE id = $1
        "#,
        message_id,
    )
    .fetch_optional(conn)
    .await
}

pub async fn get_messages_for_discussion(
    conn: &mut PgConnection,
    discussion_id: Uuid,
) -> Result<Vec<PrivateMessage>, sqlx::Error> {
    sqlx::query_as!(
        PrivateMessage,
        r#"
        SELECT *
        FROM private_messages
        WHERE discussion_id = $1
        "#,
        discussion_id,
    )
    .fetch_all(conn)
    .await
}

pub async fn get_last_messages_for_discussions(
    conn: &mut PgConnection,
    discussion_ids: Vec<Uuid>,
) -> Result<Vec<PrivateMessage>, sqlx::Error> {
    sqlx::query_as!(
        PrivateMessage,
        r#"
        SELECT pm.*
        FROM private_messages pm
        WHERE pm.id IN (
            SELECT DISTINCT ON (discussion_id) id
            FROM private_messages
            WHERE discussion_id = ANY($1)
            ORDER BY discussion_id, created_at DESC
        );
        "#,
        &discussion_ids,
    )
    .fetch_all(conn)
    .await
}

pub async fn delete_message_by_id(
    conn: &mut PgConnection,
    message_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        PrivateMessage,
        r#"
        UPDATE private_messages
        SET deleted = true
        WHERE id = $1
        "#,
        message_id,
    )
    .execute(conn)
    .await
}

pub async fn create_private_message(
    conn: &mut PgConnection,
    private_message: &PrivateMessage,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        PrivateMessage,
        r#"
        INSERT INTO private_messages (
            id,
            discussion_id,
            creator,
            created_at,
            updated_at,
            content,
            creator_encrypted_session_key,
            recipient_encrypted_session_key,
            deleted,
            seen
        )
        VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        "#,
        private_message.id,
        private_message.discussion_id,
        private_message.creator,
        private_message.created_at,
        private_message.updated_at,
        private_message.content,
        private_message.creator_encrypted_session_key,
        private_message.recipient_encrypted_session_key,
        private_message.deleted,
        private_message.seen,
    )
    .execute(conn)
    .await
}

pub async fn update_private_message(
    conn: &mut PgConnection,
    private_message: &PrivateMessage,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        PrivateMessage,
        r#"
        UPDATE private_messages
        SET updated_at = $1, content = $2
        WHERE id = $3
        "#,
        private_message.updated_at,
        private_message.content,
        private_message.id,
    )
    .execute(conn)
    .await
}
pub async fn mark_private_message_as_seen(
    conn: &mut PgConnection,
    private_message: &PrivateMessage,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        PrivateMessage,
        r#"
        UPDATE private_messages
        SET seen = $1
        WHERE id = $2
        "#,
        private_message.seen,
        private_message.id,
    )
    .execute(conn)
    .await
}
