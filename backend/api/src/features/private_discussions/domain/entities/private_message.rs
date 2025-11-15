use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;

use uuid::Uuid;

pub const PRIVATE_MESSAGE_CONTENT_MAX_LENGTH: usize = 10_000;

#[derive(Debug, Clone, Deserialize, Serialize, FromRow)]
pub struct PrivateMessage {
    pub id: Uuid,
    pub discussion_id: Uuid,
    pub creator: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: Option<DateTime<Utc>>,
    pub content: String,
    pub creator_encrypted_session_key: String,
    pub recipient_encrypted_session_key: String,
    pub deleted: bool,
    pub seen: bool,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct PrivateMessageData {
    pub id: Uuid,
    pub discussion_id: Uuid,
    pub creator: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: Option<DateTime<Utc>>,
    pub content: String,
    pub creator_encrypted_session_key: String,
    pub recipient_encrypted_session_key: String,
    pub deleted: bool,
    pub seen: bool,
}

impl PrivateMessage {
    pub fn to_private_message_data(&self) -> PrivateMessageData {
        PrivateMessageData {
            id: self.id,
            discussion_id: self.discussion_id,
            creator: self.creator,
            created_at: self.created_at,
            updated_at: self.updated_at,
            content: self.content.to_owned(),
            creator_encrypted_session_key: self.creator_encrypted_session_key.to_owned(),
            recipient_encrypted_session_key: self.recipient_encrypted_session_key.to_owned(),
            deleted: self.deleted,
            seen: self.seen,
        }
    }
}
