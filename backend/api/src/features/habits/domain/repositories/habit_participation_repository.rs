// HabitParticipation repository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::habits::domain::entities::habit_participation::HabitParticipation;

#[async_trait]
pub trait HabitParticipationRepository: Send + Sync {
    async fn create(&self, participation: &HabitParticipation) -> Result<(), String>;
    async fn update(&self, participation: &HabitParticipation) -> Result<(), String>;
    async fn get_by_id(&self, participation_id: Uuid)
        -> Result<Option<HabitParticipation>, String>;
    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Vec<HabitParticipation>, String>;
    async fn get_by_habit_id(&self, habit_id: Uuid) -> Result<Vec<HabitParticipation>, String>;
    async fn get_by_user_and_habit_id(
        &self,
        user_id: Uuid,
        habit_id: Uuid,
    ) -> Result<Option<HabitParticipation>, String>;
    async fn delete(&self, participation_id: Uuid) -> Result<(), String>;
    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String>;
    async fn get_participants_to_send_reminder_notification(
        &self,
    ) -> Result<Vec<(Uuid, Uuid, Option<String>)>, String>;
    async fn count(&self) -> Result<i64, String>;
}
