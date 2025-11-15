// HabitCategoryRepository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::habits::domain::entities::habit_category::HabitCategory;

#[async_trait]
pub trait HabitCategoryRepository: Send + Sync {
    async fn create(&self, category: &HabitCategory) -> Result<(), String>;
    async fn update(&self, category: &HabitCategory) -> Result<(), String>;
    async fn get_by_id(&self, id: Uuid) -> Result<Option<HabitCategory>, String>;
    async fn get_all(&self) -> Result<Vec<HabitCategory>, String>;
    async fn delete(&self, id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
