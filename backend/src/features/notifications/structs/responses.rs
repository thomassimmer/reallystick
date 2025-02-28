use serde::{Deserialize, Serialize};

use super::models::NotificationData;

#[derive(Serialize, Deserialize)]
pub struct NotificationResponse {
    pub code: String,
}

#[derive(Serialize, Deserialize)]
pub struct NotificationsResponse {
    pub code: String,
    pub notifications: Vec<NotificationData>,
}
