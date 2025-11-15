// Auth domain entities

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;

// Domain entities are pure business objects without infrastructure dependencies
// They are moved from structs/models
// Note: FromRow is kept for SQLx compatibility, but this is an infrastructure concern
// In a pure clean architecture, we'd have separate DTOs for database mapping

#[allow(non_snake_case)]
#[derive(Debug, Deserialize, Serialize, Clone, FromRow)]
pub struct RecoveryCode {
    pub id: Uuid,
    pub user_id: Uuid,
    pub recovery_code: String,
    pub private_key_encrypted: String,
    pub salt_used_to_derive_key_from_recovery_code: String,
}

#[allow(non_snake_case)]
#[derive(Debug, Deserialize, Serialize, Clone, Default, FromRow)]
pub struct UserToken {
    pub id: Uuid,
    pub user_id: Uuid,
    pub token_id: Uuid,
    pub expires_at: DateTime<Utc>,
    pub os: Option<String>,
    pub is_mobile: Option<bool>,
    pub browser: Option<String>,
    pub app_version: Option<String>,
    pub model: Option<String>,
    pub fcm_token: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    pub exp: i64,
    pub jti: Uuid,
    pub user_id: Uuid,
    pub username: String,
    pub is_admin: bool,
}
