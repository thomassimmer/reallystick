// PrivateDiscussion repository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::private_discussions::domain::entities::private_discussion::PrivateDiscussion;

#[async_trait]
pub trait PrivateDiscussionRepository: Send + Sync {
    async fn create(&self, discussion: &PrivateDiscussion) -> Result<(), String>;
    async fn get_by_id(&self, discussion_id: Uuid) -> Result<Option<PrivateDiscussion>, String>;
    async fn get_by_users(
        &self,
        user1_id: Uuid,
        user2_id: Uuid,
    ) -> Result<Option<PrivateDiscussion>, String>;
    async fn get_by_ids(&self, discussion_ids: Vec<Uuid>)
        -> Result<Vec<PrivateDiscussion>, String>;
    async fn count(&self) -> Result<i64, String>;
}
