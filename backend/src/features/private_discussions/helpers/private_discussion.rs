use sqlx::{postgres::PgQueryResult, PgConnection};
use uuid::Uuid;

use crate::features::private_discussions::structs::models::private_discussion::PrivateDiscussion;

pub async fn get_private_discussion_by_users(
    conn: &mut PgConnection,
    user1_id: Uuid,
    user2_id: Uuid,
) -> Result<Option<PrivateDiscussion>, sqlx::Error> {
    sqlx::query_as!(
        PrivateDiscussion,
        r#"
        WITH participants AS (
            SELECT discussion_id
            FROM private_discussion_participations
            WHERE user_id IN ($1, $2)
            GROUP BY discussion_id
            HAVING COUNT(DISTINCT user_id) = 2
        )
        SELECT pd.*
        FROM private_discussions pd
        JOIN participants p ON pd.id = p.discussion_id;
        "#,
        user1_id,
        user2_id
    )
    .fetch_optional(conn)
    .await
}

pub async fn get_private_discussions_from_ids(
    conn: &mut PgConnection,
    ids: Vec<Uuid>,
) -> Result<Vec<PrivateDiscussion>, sqlx::Error> {
    sqlx::query_as!(
        PrivateDiscussion,
        r#"
        SELECT *
        FROM private_discussions
        WHERE id = ANY($1); 
        "#,
        &ids,
    )
    .fetch_all(conn)
    .await
}

pub async fn get_private_discussion_by_id(
    conn: &mut PgConnection,
    id: Uuid,
) -> Result<Option<PrivateDiscussion>, sqlx::Error> {
    sqlx::query_as!(
        PrivateDiscussion,
        r#"
        SELECT *
        FROM private_discussions
        WHERE id = $1; 
        "#,
        &id,
    )
    .fetch_optional(conn)
    .await
}

pub async fn create_private_discussion(
    conn: &mut PgConnection,
    discussion: &PrivateDiscussion,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        PrivateDiscussion,
        r#"
        INSERT INTO private_discussions (
            id,
            created_at
        )
        VALUES ($1, $2)
        "#,
        discussion.id,
        discussion.created_at,
    )
    .execute(conn)
    .await
}
