// ChallengeDailyTracking repository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::challenges::domain::entities::challenge_daily_tracking::ChallengeDailyTracking;

#[async_trait]
pub trait ChallengeDailyTrackingRepository: Send + Sync {
    async fn get_by_id(&self, tracking_id: Uuid) -> Result<Option<ChallengeDailyTracking>, String>;
    async fn get_by_challenge_id(
        &self,
        challenge_id: Uuid,
    ) -> Result<Vec<ChallengeDailyTracking>, String>;
    async fn get_by_challenge_ids(
        &self,
        challenge_ids: Vec<Uuid>,
    ) -> Result<Vec<ChallengeDailyTracking>, String>;
    async fn create(&self, tracking: &ChallengeDailyTracking) -> Result<(), String>;
    async fn create_batch(&self, trackings: &[ChallengeDailyTracking]) -> Result<(), String>;
    async fn update(&self, tracking: &ChallengeDailyTracking) -> Result<(), String>;
    async fn delete(&self, tracking_id: Uuid) -> Result<(), String>;
    async fn delete_by_challenge_id(&self, challenge_id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
