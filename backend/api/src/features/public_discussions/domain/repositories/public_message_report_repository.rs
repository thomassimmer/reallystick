// PublicMessageReport repository trait

use async_trait::async_trait;
use uuid::Uuid;

use crate::features::public_discussions::domain::entities::public_message_report::PublicMessageReport;

#[async_trait]
pub trait PublicMessageReportRepository: Send + Sync {
    async fn create(&self, report: &PublicMessageReport) -> Result<(), String>;
    async fn delete(&self, report_id: Uuid) -> Result<(), String>;
    async fn get_by_id(&self, report_id: Uuid) -> Result<Option<PublicMessageReport>, String>;
    async fn get_all(&self) -> Result<Vec<PublicMessageReport>, String>;
    async fn get_by_reporter(&self, user_id: Uuid) -> Result<Vec<PublicMessageReport>, String>;
    async fn delete_by_user_id(&self, user_id: Uuid) -> Result<(), String>;
    async fn count(&self) -> Result<i64, String>;
}
