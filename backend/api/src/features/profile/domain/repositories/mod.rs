// Profile domain repository traits

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::profile::domain::entities::User;

#[async_trait]
pub trait UserRepository: Send + Sync {
    async fn create(&self, user: &User) -> Result<(), String>;
    async fn update(&self, user: &User) -> Result<(), String>;
    async fn update_keys(&self, user: &User) -> Result<(), String>;
    async fn get_by_id(&self, id: Uuid) -> Result<Option<User>, String>;
    async fn get_by_username(&self, username: &str) -> Result<Option<User>, String>;
    async fn get_by_ids(&self, ids: Vec<Uuid>) -> Result<Vec<User>, String>;
    async fn get_all(&self) -> Result<Vec<User>, String>;
    async fn update_deleted_at(
        &self,
        user_id: Uuid,
        deleted_at: Option<chrono::DateTime<chrono::Utc>>,
    ) -> Result<(), String>;
    async fn mark_as_deleted(&self, user_id: Uuid) -> Result<(), String>;
    async fn get_not_deleted_but_marked_as_deleted(&self) -> Result<Vec<User>, String>;
    async fn count(&self) -> Result<i64, String>;
}
