// RecoveryCodeRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::auth::domain::entities::RecoveryCode;
use crate::features::auth::domain::repositories::RecoveryCodeRepository;

pub struct RecoveryCodeRepositoryImpl {
    pool: PgPool,
}

impl RecoveryCodeRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    // These methods match the pattern used in helpers for backward compatibility
    pub async fn create_with_executor<'a, E>(
        &self,
        recovery_code: &RecoveryCode,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
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

    pub async fn get_by_user_id_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<Option<RecoveryCode>, sqlx::Error>
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

    pub async fn delete_by_user_id_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
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
}

#[async_trait]
impl RecoveryCodeRepository for RecoveryCodeRepositoryImpl {
    async fn create(&self, recovery_code: &RecoveryCode) -> Result<(), String> {
        self.create_with_executor(recovery_code, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Option<RecoveryCode>, String> {
        let recovery_code = self
            .get_by_user_id_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(recovery_code)
    }

    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String> {
        self.delete_by_user_id_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }
}
