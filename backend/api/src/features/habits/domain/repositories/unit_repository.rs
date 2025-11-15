// UnitRepository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::habits::domain::entities::unit::Unit;

#[async_trait]
pub trait UnitRepository: Send + Sync {
    async fn create(&self, unit: &Unit) -> Result<(), String>;
    async fn update(&self, unit: &Unit) -> Result<(), String>;
    async fn get_by_id(&self, id: Uuid) -> Result<Option<Unit>, String>;
    async fn get_all(&self) -> Result<Vec<Unit>, String>;
    async fn delete(&self, id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
