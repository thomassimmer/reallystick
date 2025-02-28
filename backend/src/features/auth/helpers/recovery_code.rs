use sqlx::Error;
use sqlx::{postgres::PgQueryResult, PgConnection};
use uuid::Uuid;

use crate::features::auth::structs::models::RecoveryCode;

pub async fn create_recovery_code(
    recovery_code: &RecoveryCode,
    transaction: &mut PgConnection,
) -> Result<PgQueryResult, Error> {
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
    .execute(transaction)
    .await
}

pub async fn get_recovery_code_for_user(
    user_id: Uuid,
    transaction: &mut PgConnection,
) -> Result<Option<RecoveryCode>, Error> {
    sqlx::query_as!(
        RecoveryCode,
        r#"
        SELECT *
        FROM recovery_codes 
        WHERE user_id = $1
        "#,
        user_id
    )
    .fetch_optional(transaction)
    .await
}

pub async fn delete_recovery_code_for_user(
    user_id: Uuid,
    transaction: &mut PgConnection,
) -> Result<PgQueryResult, Error> {
    sqlx::query_as!(
        RecoveryCode,
        r#"
        DELETE
        FROM recovery_codes 
        WHERE user_id = $1
        "#,
        user_id
    )
    .execute(transaction)
    .await
}
