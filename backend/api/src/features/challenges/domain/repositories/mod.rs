// Challenges domain repository traits

pub mod challenge_daily_tracking_repository;
pub mod challenge_participation_repository;

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::challenges::domain::entities::challenge::Challenge;

#[async_trait]
pub trait ChallengeRepository: Send + Sync {
    async fn create(&self, challenge: &Challenge) -> Result<(), String>;
    async fn update(&self, challenge: &Challenge) -> Result<(), String>;
    async fn get_by_id(&self, id: Uuid) -> Result<Option<Challenge>, String>;
    async fn get_all(&self) -> Result<Vec<Challenge>, String>;
    async fn get_created(&self, user_id: Uuid) -> Result<Vec<Challenge>, String>;
    async fn get_created_and_joined(&self, user_id: Uuid) -> Result<Vec<Challenge>, String>;
    async fn delete(&self, id: Uuid) -> Result<(), String>;
    async fn mark_as_deleted_for_user(&self, user_id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
