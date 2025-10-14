use sqlx::postgres::PgQueryResult;
use sqlx::{Error, Executor, Postgres};
use uuid::Uuid;

use crate::features::auth::structs::models::RecoveryCode;

pub async fn create_recovery_code<'a, E>(
    recovery_code: &RecoveryCode,
    executor: E,
) -> Result<PgQueryResult, Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query!(
        r#"
        INSERT INTO recovery_codes (id, user_id, recovery_code, private_key_encrypted, salt_used_to_derive_key_from_recovery_code)
        VALUES ($1, $2, $3, $4, $5)
        "#,
        recovery_code.id,
        recovery_code.user_id,
        recovery_code.recovery_code,
        recovery_code.private_key_encrypted,
        recovery_code.salt_used_to_derive_key_from_recovery_code,
    )
    .execute(executor)
    .await
}

pub async fn get_recovery_code_for_user<'a, E>(
    user_id: Uuid,
    executor: E,
) -> Result<Option<RecoveryCode>, Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        RecoveryCode,
        r#"
        SELECT *
        FROM recovery_codes 
        WHERE user_id = $1
        "#,
        user_id
    )
    .fetch_optional(executor)
    .await
}

pub async fn delete_recovery_code_for_user<'a, E>(
    user_id: Uuid,
    executor: E,
) -> Result<PgQueryResult, Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        RecoveryCode,
        r#"
        DELETE
        FROM recovery_codes 
        WHERE user_id = $1
        "#,
        user_id
    )
    .execute(executor)
    .await
}
