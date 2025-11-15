// PublicMessage repository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::public_discussions::domain::entities::public_message::PublicMessage;

#[async_trait]
pub trait PublicMessageRepository: Send + Sync {
    async fn create(&self, message: &PublicMessage) -> Result<(), String>;
    async fn update(&self, message: &PublicMessage) -> Result<(), String>;
    async fn update_like_count(&self, message: &PublicMessage) -> Result<(), String>;
    async fn update_reply_count(&self, message: &PublicMessage) -> Result<(), String>;
    async fn get_by_id(&self, message_id: Uuid) -> Result<Option<PublicMessage>, String>;
    async fn get_by_habit_id(&self, habit_id: Uuid) -> Result<Vec<PublicMessage>, String>;
    async fn get_by_challenge_id(&self, challenge_id: Uuid) -> Result<Vec<PublicMessage>, String>;
    async fn get_replies(&self, message_id: Uuid) -> Result<Vec<PublicMessage>, String>;
    async fn get_by_creator(&self, user_id: Uuid) -> Result<Vec<PublicMessage>, String>;
    async fn get_reported(&self) -> Result<Vec<PublicMessage>, String>;
    async fn get_reported_by_user(&self, user_id: Uuid) -> Result<Vec<PublicMessage>, String>;
    async fn delete(&self, message: &PublicMessage) -> Result<(), String>;
    async fn mark_as_deleted_for_user(&self, user_id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
