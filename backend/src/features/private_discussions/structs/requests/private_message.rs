use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct UpdatePrivateMessageParams {
    pub message_id: Uuid,
}

#[derive(Deserialize)]
pub struct DeletePrivateMessageParams {
    pub message_id: Uuid,
}

#[derive(Deserialize)]
pub struct ListenForNewMessages {
    pub access_token: String,
}

#[derive(Deserialize)]
pub struct MarkAsSeenPrivateMessageParams {
    pub message_id: Uuid,
}

#[derive(Deserialize)]
pub struct GetPrivateMessagesParams {
    pub discussion_id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct PrivateMessageUpdateRequest {
    pub content: String,
}

#[derive(Deserialize, Serialize)]
pub struct PrivateMessageCreateRequest {
    pub discussion_id: Uuid,
    pub content: String,
    pub creator_encrypted_session_key: String,
    pub recipient_encrypted_session_key: String,
}
