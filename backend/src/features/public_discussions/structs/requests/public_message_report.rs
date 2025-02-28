use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct DeletePublicMessageReportParams {
    pub message_report_id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct PublicMessageReportCreateRequest {
    pub message_id: Uuid,
    pub reason: String,
}
