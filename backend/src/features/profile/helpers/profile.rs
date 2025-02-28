use sqlx::{postgres::PgQueryResult, Executor, Postgres};
use uuid::Uuid;

use crate::features::profile::structs::models::User;

pub async fn create_user<'a, E>(
    executor: E,
    user: User,
) -> Result<PgQueryResult, sqlx::Error> where
E: Executor<'a, Database = Postgres>,
{
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
            password_is_expired,
            is_admin,
            public_key,
            private_key_encrypted,
            salt_used_to_derive_key_from_password,
            notifications_enabled, 
            notifications_for_private_messages_enabled, 
            notifications_for_public_message_liked_enabled, 
            notifications_for_public_message_replies_enabled, 
            notifications_user_joined_your_challenge_enabled, 
            notifications_user_duplicated_your_challenge_enabled
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
        "#,
        user.id,
        user.username,
        user.password,
        user.otp_verified,
        user.otp_base32,
        user.otp_auth_url,
        user.created_at,
        user.updated_at,
        user.password_is_expired,
        user.is_admin,
        user.public_key,
        user.private_key_encrypted,
        user.salt_used_to_derive_key_from_password,
        user.notifications_enabled, 
        user.notifications_for_private_messages_enabled, 
        user.notifications_for_public_message_liked_enabled, 
        user.notifications_for_public_message_replies_enabled, 
        user.notifications_user_joined_your_challenge_enabled, 
        user.notifications_user_duplicated_your_challenge_enabled, 
    )
    .execute(executor)
    .await
}

pub async fn update_user<'a, E>(
    executor: E,
    user: &User,
) -> Result<PgQueryResult, sqlx::Error> where
E: Executor<'a, Database = Postgres>,
{
    sqlx::query!(
        r#"
        UPDATE users
        SET 
            username = $1,
            locale = $2,
            theme = $3,
            age_category = $4,
            gender = $5,
            continent = $6,
            country = $7,
            region = $8,
            activity = $9,
            financial_situation = $10,
            lives_in_urban_area = $11,
            relationship_status = $12,
            level_of_education = $13,
            has_children = $14,
            has_seen_questions = $15,
            notifications_enabled = $16,
            notifications_for_private_messages_enabled = $17,
            notifications_for_public_message_liked_enabled = $18,
            notifications_for_public_message_replies_enabled = $19,
            notifications_user_joined_your_challenge_enabled = $20,
            notifications_user_duplicated_your_challenge_enabled = $21
        WHERE id = $22
        "#,
        user.username,
        user.locale,
        user.theme,
        user.age_category,
        user.gender,
        user.continent,
        user.country,
        user.region,
        user.activity,
        user.financial_situation,
        user.lives_in_urban_area,
        user.relationship_status,
        user.level_of_education,
        user.has_children,
        user.has_seen_questions,
        user.notifications_enabled, 
        user.notifications_for_private_messages_enabled, 
        user.notifications_for_public_message_liked_enabled, 
        user.notifications_for_public_message_replies_enabled, 
        user.notifications_user_joined_your_challenge_enabled, 
        user.notifications_user_duplicated_your_challenge_enabled, 
        user.id,
    )
    .execute(executor)
    .await
}

pub async fn update_user_keys<'a, E>(
    executor: E,
    user: &User,
) -> Result<PgQueryResult, sqlx::Error> where
E: Executor<'a, Database = Postgres>,
{
    sqlx::query!(
        r#"
        UPDATE users
        SET 
           public_key = $1,
           private_key_encrypted = $2,
           salt_used_to_derive_key_from_password = $3
        WHERE id = $4
        "#,
        user.public_key,
        user.private_key_encrypted,
        user.salt_used_to_derive_key_from_password,
        user.id,
    )
    .execute(executor)
    .await
}

pub async fn get_user_by_username<'a, E>(
    executor: E,
    username: &str,
) -> Result<Option<User>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    let user = sqlx::query_as!(
        User,
        "SELECT * FROM users WHERE username = $1",
        username
    )
    .fetch_optional(executor)
    .await?;

    Ok(user)
}

pub async fn get_user_by_id<'a, E>(
    executor: E,
    id: Uuid,
) -> Result<Option<User>, sqlx::Error> where
E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        User,
        r#"
        SELECT *
        FROM users
        WHERE id = $1
        "#,
        id,
    )
    .fetch_optional(executor)
    .await
}

pub async fn get_users_by_id<'a, E>(
    executor: E,
    ids: Vec<Uuid>,
) -> Result<Vec<User>, sqlx::Error> where
E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        User,
        r#"
        SELECT *
        FROM users
        WHERE id = ANY($1)
        "#,
        &ids,
    )
    .fetch_all(executor)
    .await
}

pub async fn delete_user_by_id<'a, E>(
    executor: E,
    user_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error> where
E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        User,
        r#"
        DELETE
        from users
        WHERE id = $1
        "#,
        user_id,
    )
    .execute(executor)
    .await
}
