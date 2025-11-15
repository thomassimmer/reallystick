// Notification repository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::notifications::domain::entities::Notification;

#[async_trait]
pub trait NotificationRepository: Send + Sync {
    async fn create(&self, notification: &Notification) -> Result<(), String>;
    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Vec<Notification>, String>;
    async fn get_by_id(&self, notification_id: Uuid) -> Result<Option<Notification>, String>;
    async fn mark_as_seen(&self, notification_id: Uuid) -> Result<(), String>;
    async fn delete(&self, notification_id: Uuid) -> Result<(), String>;
    async fn delete_all_by_user_id(&self, user_id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
