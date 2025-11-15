use serde::{Deserialize, Serialize};

use crate::features::notifications::domain::entities::NotificationData;

#[derive(Serialize, Deserialize)]
pub struct NotificationResponse {
    pub code: String,
}

#[derive(Serialize, Deserialize)]
pub struct NotificationsResponse {
    pub code: String,
    pub notifications: Vec<NotificationData>,
}
