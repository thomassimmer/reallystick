// Auth domain repository traits

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::auth::domain::entities::{RecoveryCode, UserToken};

#[async_trait]
pub trait RecoveryCodeRepository: Send + Sync {
    async fn create(&self, recovery_code: &RecoveryCode) -> Result<(), String>;
    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Option<RecoveryCode>, String>;
    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String>;
}

#[async_trait]
pub trait UserTokenRepository: Send + Sync {
    async fn create(&self, token: &UserToken) -> Result<(), String>;
    async fn get_by_user_and_token_id(
        &self,
        user_id: Uuid,
        token_id: Uuid,
    ) -> Result<Option<UserToken>, String>;
    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Vec<UserToken>, String>;
    async fn update(&self, token: &UserToken) -> Result<(), String>;
    async fn delete_by_user_and_token_id(
        &self,
        user_id: Uuid,
        token_id: Uuid,
    ) -> Result<(), String>;
    async fn delete_by_token_id(&self, token_id: Uuid) -> Result<(), String>;
    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String>;
    async fn delete_expired(&self) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
