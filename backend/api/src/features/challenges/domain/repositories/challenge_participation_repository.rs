// ChallengeParticipation repository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::challenges::domain::entities::challenge_participation::ChallengeParticipation;

#[async_trait]
pub trait ChallengeParticipationRepository: Send + Sync {
    async fn create(&self, participation: &ChallengeParticipation) -> Result<(), String>;
    async fn update(&self, participation: &ChallengeParticipation) -> Result<(), String>;
    async fn get_by_id(
        &self,
        participation_id: Uuid,
    ) -> Result<Option<ChallengeParticipation>, String>;
    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Vec<ChallengeParticipation>, String>;
    async fn get_by_challenge_id(
        &self,
        challenge_id: Uuid,
    ) -> Result<Vec<ChallengeParticipation>, String>;
    async fn get_ongoing_by_user_and_challenge(
        &self,
        user_id: Uuid,
        challenge_id: Uuid,
    ) -> Result<Option<ChallengeParticipation>, String>;
    async fn delete(&self, participation_id: Uuid) -> Result<(), String>;
    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
    async fn get_participants_to_send_reminder_notification(
        &self,
    ) -> Result<Vec<(Uuid, Uuid, Option<String>)>, String>;
}
