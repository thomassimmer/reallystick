use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;

use uuid::Uuid;

#[derive(Debug, Deserialize, Serialize, Clone, FromRow)]
pub struct Notification {
    pub id: Uuid,
    pub user_id: Uuid,
    pub created_at: DateTime<Utc>,
    pub title: String,
    pub body: String,
    pub url: Option<String>,
    pub seen: bool,
}

impl Notification {
    pub fn to_notification_data(&self) -> NotificationData {
        NotificationData {
            id: self.id,
            user_id: self.user_id,
            created_at: self.created_at,
            title: self.title.clone(),
            body: self.body.clone(),
            url: self.url.clone(),
            seen: self.seen,
        }
    }
}

#[derive(Serialize, Debug, Deserialize)]
pub struct NotificationData {
    pub id: Uuid,
    pub user_id: Uuid,
    pub created_at: DateTime<Utc>,
    pub title: String,
    pub body: String,
    pub url: Option<String>,
    pub seen: bool,
}
