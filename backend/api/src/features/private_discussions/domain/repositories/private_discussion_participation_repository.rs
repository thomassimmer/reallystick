// PrivateDiscussionParticipation repository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::private_discussions::domain::entities::private_discussion_participation::PrivateDiscussionParticipation;

#[async_trait]
pub trait PrivateDiscussionParticipationRepository: Send + Sync {
    async fn create(&self, participation: &PrivateDiscussionParticipation) -> Result<(), String>;
    async fn update(&self, participation: &PrivateDiscussionParticipation) -> Result<(), String>;
    async fn get_by_id(
        &self,
        participation_id: Uuid,
    ) -> Result<Option<PrivateDiscussionParticipation>, String>;
    async fn get_by_user_id(
        &self,
        user_id: Uuid,
    ) -> Result<Vec<PrivateDiscussionParticipation>, String>;
    async fn get_by_user_and_discussion(
        &self,
        user_id: Uuid,
        discussion_id: Uuid,
    ) -> Result<Option<PrivateDiscussionParticipation>, String>;
    async fn get_by_discussion_id(
        &self,
        discussion_id: Uuid,
    ) -> Result<Vec<PrivateDiscussionParticipation>, String>;
    async fn get_recipients(
        &self,
        discussion_ids: Vec<Uuid>,
        user_id: Uuid,
    ) -> Result<Vec<PrivateDiscussionParticipation>, String>;
}
