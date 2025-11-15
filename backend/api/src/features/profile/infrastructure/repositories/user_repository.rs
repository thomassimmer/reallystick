// UserRepository implementation using SQLx
// Supports both PgPool and transactions via Executor trait

use async_trait::async_trait;
use sqlx::{postgres::PgQueryResult, Executor, PgPool, Postgres};
use uuid::Uuid;

use crate::features::profile::domain::entities::User;
use crate::features::profile::domain::repositories::UserRepository;

pub struct UserRepositoryImpl {
    pool: PgPool,
}

impl UserRepositoryImpl {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Transaction-aware methods that accept Executor
    pub async fn create_with_executor<'a, E>(
        &self,
        user: &User,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            INSERT INTO users (
                id, username, password, locale, theme, timezone,
                otp_verified, otp_base32, otp_auth_url, created_at, updated_at,
                password_is_expired, has_seen_questions, is_admin,
                public_key, private_key_encrypted, salt_used_to_derive_key_from_password,
                notifications_enabled, notifications_for_private_messages_enabled,
                notifications_for_public_message_liked_enabled,
                notifications_for_public_message_replies_enabled,
                notifications_user_joined_your_challenge_enabled,
                notifications_user_duplicated_your_challenge_enabled
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23)
            "#,
            user.id,
            user.username,
            user.password,
            user.locale,
            user.theme,
            user.timezone,
            user.otp_verified,
            user.otp_base32,
            user.otp_auth_url,
            user.created_at,
            user.updated_at,
            user.password_is_expired,
            user.has_seen_questions,
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

    pub async fn update_with_executor<'a, E>(
        &self,
        user: &User,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE users
            SET 
                username = $1, locale = $2, theme = $3, age_category = $4,
                gender = $5, continent = $6, country = $7, region = $8,
                activity = $9, financial_situation = $10, lives_in_urban_area = $11,
                relationship_status = $12, level_of_education = $13, has_children = $14,
                has_seen_questions = $15, notifications_enabled = $16,
                notifications_for_private_messages_enabled = $17,
                notifications_for_public_message_liked_enabled = $18,
                notifications_for_public_message_replies_enabled = $19,
                notifications_user_joined_your_challenge_enabled = $20,
                notifications_user_duplicated_your_challenge_enabled = $21,
                timezone = $22, otp_verified = $23, otp_auth_url = $24,
                otp_base32 = $25, password_is_expired = $26, password = $27
            WHERE id = $28
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
            user.timezone,
            user.otp_verified,
            user.otp_auth_url,
            user.otp_base32,
            user.password_is_expired,
            user.password,
            user.id,
        )
        .execute(executor)
        .await
    }

    pub async fn update_keys_with_executor<'a, E>(
        &self,
        user: &User,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
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

    pub async fn get_by_id_with_executor<'a, E>(
        &self,
        id: Uuid,
        executor: E,
    ) -> Result<Option<User>, sqlx::Error>
    where
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

    pub async fn get_by_username_with_executor<'a, E>(
        &self,
        username: &str,
        executor: E,
    ) -> Result<Option<User>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            User,
            r#"
            SELECT *
            FROM users
            WHERE username = $1
            "#,
            username
        )
        .fetch_optional(executor)
        .await
    }

    pub async fn get_by_ids_with_executor<'a, E>(
        &self,
        ids: Vec<Uuid>,
        executor: E,
    ) -> Result<Vec<User>, sqlx::Error>
    where
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

    pub async fn get_all_with_executor<'a, E>(&self, executor: E) -> Result<Vec<User>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            User,
            r#"
            SELECT *
            FROM users
            WHERE deleted_at is null
            "#,
        )
        .fetch_all(executor)
        .await
    }

    pub async fn update_deleted_at_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        deleted_at: Option<chrono::DateTime<chrono::Utc>>,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE users
            SET deleted_at = $1
            WHERE id = $2
            "#,
            deleted_at,
            user_id,
        )
        .execute(executor)
        .await
    }

    pub async fn mark_as_deleted_with_executor<'a, E>(
        &self,
        user_id: Uuid,
        executor: E,
    ) -> Result<PgQueryResult, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query!(
            r#"
            UPDATE users
            SET
                is_deleted = true,
                age_category = null,
                gender = null,
                continent = null,
                country = null,
                region = null,
                activity = null,
                financial_situation = null,
                lives_in_urban_area = null,
                relationship_status = null,
                level_of_education = null,
                has_children = null
            WHERE id = $1
            "#,
            user_id,
        )
        .execute(executor)
        .await
    }

    pub async fn get_not_deleted_but_marked_as_deleted_with_executor<'a, E>(
        &self,
        executor: E,
    ) -> Result<Vec<User>, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        sqlx::query_as!(
            User,
            r#"
            SELECT *
            FROM users
            WHERE
                deleted_at is not null AND
                is_deleted = false
            "#,
        )
        .fetch_all(executor)
        .await
    }

    pub async fn count_with_executor<'a, E>(&self, executor: E) -> Result<i64, sqlx::Error>
    where
        E: Executor<'a, Database = Postgres>,
    {
        let row = sqlx::query!(
            r#"
            SELECT COUNT(*) as count
            FROM users
            "#,
        )
        .fetch_one(executor)
        .await?;

        Ok(row.count.unwrap_or(0))
    }
}

#[async_trait]
impl UserRepository for UserRepositoryImpl {
    async fn create(&self, user: &User) -> Result<(), String> {
        self.create_with_executor(user, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update(&self, user: &User) -> Result<(), String> {
        self.update_with_executor(user, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn update_keys(&self, user: &User) -> Result<(), String> {
        self.update_keys_with_executor(user, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_by_id(&self, id: Uuid) -> Result<Option<User>, String> {
        let user = self
            .get_by_id_with_executor(id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(user)
    }

    async fn get_by_username(&self, username: &str) -> Result<Option<User>, String> {
        let user = self
            .get_by_username_with_executor(username, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(user)
    }

    async fn get_by_ids(&self, ids: Vec<Uuid>) -> Result<Vec<User>, String> {
        let users = self
            .get_by_ids_with_executor(ids, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(users)
    }

    async fn get_all(&self) -> Result<Vec<User>, String> {
        sqlx::query_as!(
            User,
            r#"
            SELECT *
            FROM users
            WHERE deleted_at is null
            "#,
        )
        .fetch_all(&self.pool)
        .await
        .map_err(|e| e.to_string())
    }

    async fn update_deleted_at(
        &self,
        user_id: Uuid,
        deleted_at: Option<chrono::DateTime<chrono::Utc>>,
    ) -> Result<(), String> {
        self.update_deleted_at_with_executor(user_id, deleted_at, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn mark_as_deleted(&self, user_id: Uuid) -> Result<(), String> {
        self.mark_as_deleted_with_executor(user_id, &self.pool)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }

    async fn get_not_deleted_but_marked_as_deleted(&self) -> Result<Vec<User>, String> {
        self.get_not_deleted_but_marked_as_deleted_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())
    }

    async fn count(&self) -> Result<i64, String> {
        self.count_with_executor(&self.pool)
            .await
            .map_err(|e| e.to_string())
    }
}
