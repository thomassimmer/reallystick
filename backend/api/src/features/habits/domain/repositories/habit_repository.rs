// HabitRepository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::habits::domain::entities::habit::Habit;

#[async_trait]
pub trait HabitRepository: Send + Sync {
    async fn create(&self, habit: &Habit) -> Result<(), String>;
    async fn update(&self, habit: &Habit) -> Result<(), String>;
    async fn get_by_id(&self, id: Uuid) -> Result<Option<Habit>, String>;
    async fn get_all(&self) -> Result<Vec<Habit>, String>;
    async fn get_reviewed_and_personal(&self, user_id: Uuid) -> Result<Vec<Habit>, String>;
    async fn delete(&self, id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
