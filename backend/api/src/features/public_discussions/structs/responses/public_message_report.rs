use serde::{Deserialize, Serialize};

use crate::features::public_discussions::structs::models::{
    public_message::PublicMessageData, public_message_report::PublicMessageReportData,
};

#[derive(Serialize, Deserialize)]
pub struct PublicMessageReportResponse {
    pub code: String,
    pub message_report: Option<PublicMessageReportData>,
}

#[derive(Serialize, Deserialize)]
pub struct PublicMessageReportsResponse {
    pub code: String,
    pub message_reports: Vec<PublicMessageReportData>,
    pub messages: Vec<PublicMessageData>,
}
