use sqlx::{postgres::PgQueryResult, PgConnection};
use uuid::Uuid;

use crate::features::profile::structs::models::User;

pub async fn create_user(
    conn: &mut PgConnection,
    user: User,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query!(
        r#"
        INSERT INTO users (
            id,
            username,
            password,
            otp_verified,
            otp_base32,
            otp_auth_url,
            created_at,
            updated_at,
            recovery_codes,
            password_is_expired,
            is_admin
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        "#,
        user.id,
        user.username,
        user.password,
        user.otp_verified,
        user.otp_base32,
        user.otp_auth_url,
        user.created_at,
        user.updated_at,
        user.recovery_codes,
        user.password_is_expired,
        user.is_admin
    )
    .execute(conn)
    .await
}

pub async fn get_user_by_username(
    conn: &mut PgConnection,
    username_lower: String,
) -> Result<Option<User>, sqlx::Error> {
    sqlx::query_as!(
        User,
        r#"
        SELECT *
        FROM users
        WHERE username = $1
        "#,
        username_lower,
    )
    .fetch_optional(conn)
    .await
}

pub async fn get_user_by_id(
    conn: &mut PgConnection,
    id: Uuid,
) -> Result<Option<User>, sqlx::Error> {
    sqlx::query_as!(
        User,
        r#"
        SELECT *
        FROM users
        WHERE id = $1
        "#,
        id,
    )
    .fetch_optional(conn)
    .await
}

pub async fn delete_user_by_id(
    conn: &mut PgConnection,
    user_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        User,
        r#"
        DELETE
        from users
        WHERE id = $1
        "#,
        user_id,
    )
    .execute(conn)
    .await
}
