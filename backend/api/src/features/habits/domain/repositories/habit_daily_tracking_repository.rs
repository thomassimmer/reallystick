// HabitDailyTracking repository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::habits::domain::entities::habit_daily_tracking::HabitDailyTracking;

#[async_trait]
pub trait HabitDailyTrackingRepository: Send + Sync {
    async fn create(&self, tracking: &HabitDailyTracking) -> Result<(), String>;
    async fn update(&self, tracking: &HabitDailyTracking) -> Result<(), String>;
    async fn get_by_id(&self, tracking_id: Uuid) -> Result<Option<HabitDailyTracking>, String>;
    async fn get_by_user_id(&self, user_id: Uuid) -> Result<Vec<HabitDailyTracking>, String>;
    async fn get_by_habit_id(&self, habit_id: Uuid) -> Result<Vec<HabitDailyTracking>, String>;
    async fn delete(&self, tracking_id: Uuid) -> Result<(), String>;
    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
