use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetPublicMessageParams {
    pub message_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdatePublicMessageParams {
    pub message_id: Uuid,
}

#[derive(Deserialize)]
pub struct DeletePublicMessageParams {
    pub message_id: Uuid,
    pub deleted_by_admin: bool,
}

#[derive(Deserialize)]
pub struct GetPublicMessagesParams {
    pub habit_id: Option<Uuid>,
    pub challenge_id: Option<Uuid>,
}

#[derive(Deserialize)]
pub struct GetPublicMessageRepliesParams {
    pub message_id: Uuid,
}

#[derive(Deserialize)]
pub struct GetPublicMessageParentsParams {
    pub message_id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct PublicMessageUpdateRequest {
    pub content: String,
}

#[derive(Deserialize, Serialize)]
pub struct PublicMessageCreateRequest {
    pub habit_id: Option<Uuid>,
    pub challenge_id: Option<Uuid>,
    pub replies_to: Option<Uuid>,
    pub content: String,
    pub thread_id: Option<Uuid>,
}
