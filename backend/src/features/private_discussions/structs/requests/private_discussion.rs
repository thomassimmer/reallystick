use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetPrivateDiscussionMessagesParams {
    pub discussion_id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct PrivateDiscussionCreateRequest {
    pub recipient: Uuid,
    pub color: String,
}
