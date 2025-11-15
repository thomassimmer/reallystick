use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;

pub const PUBLIC_MESSAGE_CONTENT_MAX_LENGTH: usize = 2000;

#[derive(Debug, Clone, Deserialize, Serialize, FromRow)]
pub struct PublicMessage {
    pub id: Uuid,
    pub habit_id: Option<Uuid>,
    pub challenge_id: Option<Uuid>,
    pub creator: Uuid,
    pub thread_id: Uuid,
    pub replies_to: Option<Uuid>,
    pub created_at: DateTime<Utc>,
    pub updated_at: Option<DateTime<Utc>>,
    pub content: String,
    pub like_count: i32,
    pub reply_count: i32,
    pub deleted_by_creator: bool,
    pub deleted_by_admin: bool,
    pub language_code: Option<String>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct PublicMessageData {
    pub id: Uuid,
    pub habit_id: Option<Uuid>,
    pub challenge_id: Option<Uuid>,
    pub creator: Uuid,
    pub thread_id: Uuid,
    pub replies_to: Option<Uuid>,
    pub created_at: DateTime<Utc>,
    pub updated_at: Option<DateTime<Utc>>,
    pub content: String,
    pub like_count: i32,
    pub reply_count: i32,
    pub deleted_by_creator: bool,
    pub deleted_by_admin: bool,
    pub language_code: Option<String>,
}

impl PublicMessage {
    pub fn to_public_message_data(&self) -> PublicMessageData {
        PublicMessageData {
            id: self.id,
            habit_id: self.habit_id,
            challenge_id: self.challenge_id,
            creator: self.creator,
            thread_id: self.thread_id,
            replies_to: self.replies_to,
            created_at: self.created_at,
            updated_at: self.updated_at,
            content: self.content.to_owned(),
            like_count: self.like_count,
            reply_count: self.reply_count,
            deleted_by_creator: self.deleted_by_creator,
            deleted_by_admin: self.deleted_by_admin,
            language_code: self.language_code.to_owned(),
        }
    }
}
