// PublicMessageLike repository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::public_discussions::domain::entities::public_message::PublicMessage;
use crate::features::public_discussions::domain::entities::public_message_like::PublicMessageLike;

#[async_trait]
pub trait PublicMessageLikeRepository: Send + Sync {
    async fn create(&self, like: &PublicMessageLike) -> Result<(), String>;
    async fn delete(&self, like_id: Uuid) -> Result<(), String>;
    async fn get_by_message_and_user(
        &self,
        message_id: Uuid,
        user_id: Uuid,
    ) -> Result<Option<PublicMessageLike>, String>;
    async fn get_messages_by_user(&self, user_id: Uuid) -> Result<Vec<PublicMessage>, String>;
    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
