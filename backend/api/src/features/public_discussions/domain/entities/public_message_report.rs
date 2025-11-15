use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;

pub const PUBLIC_MESSAGE_REPORT_CONTENT_MAX_LENGTH: usize = 2000;

#[derive(Debug, Clone, Deserialize, Serialize, FromRow)]
pub struct PublicMessageReport {
    pub id: Uuid,
    pub message_id: Uuid,
    pub reporter: Uuid,
    pub created_at: DateTime<Utc>,
    pub reason: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct PublicMessageReportData {
    pub id: Uuid,
    pub message_id: Uuid,
    pub reporter: Uuid,
    pub created_at: DateTime<Utc>,
    pub reason: String,
}

impl PublicMessageReport {
    pub fn to_public_message_report_data(&self) -> PublicMessageReportData {
        PublicMessageReportData {
            id: self.id,
            message_id: self.message_id,
            reporter: self.reporter,
            created_at: self.created_at,
            reason: self.reason.to_owned(),
        }
    }
}
