use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;

use super::private_message::PrivateMessageData;

#[derive(Debug, Clone, Deserialize, Serialize, FromRow)]
pub struct PrivateDiscussion {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct PrivateDiscussionData {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub color: Option<String>,
    pub has_blocked: Option<bool>,
    pub last_message: Option<PrivateMessageData>,
    pub recipient_id: Option<Uuid>,
    pub unseen_messages: i64,
}

impl PrivateDiscussion {
    pub fn to_private_discussion_data(
        &self,
        color: Option<String>,
        has_blocked: Option<bool>,
        last_message: Option<PrivateMessageData>,
        recipient_id: Option<Uuid>,
        unseen_messages: i64,
    ) -> PrivateDiscussionData {
        PrivateDiscussionData {
            id: self.id,
            created_at: self.created_at,
            color,
            has_blocked,
            last_message,
            recipient_id,
            unseen_messages,
        }
    }
}
