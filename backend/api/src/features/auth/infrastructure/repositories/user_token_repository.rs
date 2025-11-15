// UserTokenRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::auth::domain::entities::UserToken;
use crate::features::auth::domain::repositories::UserTokenRepository;

pub struct UserTokenRepositoryImpl {
    pool: PgPool,
}

impl UserTokenRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        token: &UserToken,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO user_tokens (id, user_id, token_id, expires_at, os, is_mobile, browser, app_version, model)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            "#,
            token.id,
            token.user_id,
            token.token_id,
            token.expires_at,
            token.os,
            token.is_mobile,
            token.browser,
            token.app_version,
            token.model
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_user_and_token_id_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        token_id: Uuid,
        executor: E,
    ) -> Result<Option<UserToken>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            UserToken,
            r#"
            SELECT *
            FROM user_tokens
            WHERE user_id = $1 AND token_id = $2
            "#,
            user_id,
            token_id
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn delete_by_token_id_with_executor<'a, E>(
        &self,
        token_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE
            FROM user_tokens
            WHERE token_id = $1
            "#,
            token_id
        )
        .execute(executor)
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
            FROM user_tokens
            WHERE user_id = $1
            "#,
            user_id
        )
        .execute(executor)
        .await
    }

    pub async fn get_by_user_id_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<Vec<UserToken>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            UserToken,
            r#"
            SELECT *
            FROM user_tokens
            WHERE user_id = $1
            "#,
            user_id
        )
        .fetch_all(executor)
        .await
    }

    pub async fn update_with_executor<'a, E>(
        &self,
        token: &UserToken,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE user_tokens SET fcm_token = $1 WHERE id = $2
            "#,
            token.fcm_token,
            token.id
        )
        .execute(executor)
        .await
    }

    pub async fn delete_expired_with_executor<'a, E>(
        &self,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            DELETE
            FROM user_tokens
            WHERE expires_at < NOW()
            "#,
        )
        .execute(executor)
        .await
    }
}

#[async_trait]
impl UserTokenRepository for UserTokenRepositoryImpl {
    async fn create(&self, token: &UserToken) -> Result<(), String> {
        self.create_with_executor(token, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_user_and_token_id(
        &self,
        user_id: Uuid,
        token_id: Uuid,
    ) -> Result<Option<UserToken>, String> {
        let token = self
            .get_by_user_and_token_id_with_executor(user_id, token_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(token)
    }

    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Vec<UserToken>, String> {
        let tokens = self
            .get_by_user_id_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(tokens)
    }

    async fn update(&self, token: &UserToken) -> Result<(), String> {
        self.update_with_executor(token, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete_by_user_and_token_id(
        &self,
        user_id: Uuid,
        token_id: Uuid,
    ) -> Result<(), String> {
        // This can be implemented using delete_by_token_id if needed
        sqlx::query!(
            r#"
            DELETE
            FROM user_tokens
            WHERE user_id = $1 AND token_id = $2
            "#,
            user_id,
            token_id
        )
        .execute(&self.pool)
        .await
        .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete_by_token_id(&self, token_id: Uuid) -> Result<(), String> {
        self.delete_by_token_id_with_executor(token_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String> {
        self.delete_by_user_id_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn delete_expired(&self) -> Result<(), String> {
        self.delete_expired_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn count(&self) -> Result<i64, String> {
        let row = sqlx::query!(
            r#"
            SELECT COUNT(*) as count
            FROM user_tokens
            "#,
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|e| e.to_string())?;

        Ok(row.count.unwrap_or(0))
    }
}
