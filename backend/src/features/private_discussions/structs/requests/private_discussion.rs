use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetPrivateDiscussionMessagesParams {
    pub discussion_id: Uuid,
}

#[derive(Deserialize)]
pub struct GetPrivateDiscussionMessagesQuery {
    pub before_date: Option<DateTime<Utc>>,
}

#[derive(Deserialize, Serialize)]
pub struct PrivateDiscussionCreateRequest {
    pub recipient: Uuid,
    pub color: String,
}
