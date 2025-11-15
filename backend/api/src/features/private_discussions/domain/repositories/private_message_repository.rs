// PrivateMessage repository trait

use async_trait::async_trait;
use chrono::{DateTime, Utc};
use uuid::Uuid;

use crate::features::private_discussions::domain::entities::private_message::PrivateMessage;

#[async_trait]
pub trait PrivateMessageRepository: Send + Sync {
    async fn create(&self, message: &PrivateMessage) -> Result<(), String>;
    async fn update(&self, message: &PrivateMessage) -> Result<(), String>;
    async fn get_by_id(&self, message_id: Uuid) -> Result<Option<PrivateMessage>, String>;
    async fn get_by_discussion_id(
        &self,
        discussion_id: Uuid,
        before_date: Option<DateTime<Utc>>,
    ) -> Result<Vec<PrivateMessage>, String>;
    async fn get_last_messages_for_discussions(
        &self,
        discussion_ids: Vec<Uuid>,
    ) -> Result<Vec<PrivateMessage>, String>;
    async fn get_unseen_count_for_discussions(
        &self,
        discussion_ids: Vec<Uuid>,
        user_id: Uuid,
    ) -> Result<Vec<(Uuid, i64)>, String>;
    async fn mark_as_seen(
        &self,
        discussion_id: Uuid,
        user_id: Uuid,
        before_date: DateTime<Utc>,
    ) -> Result<(), String>;
    async fn delete(&self, message_id: Uuid) -> Result<(), String>;
    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
