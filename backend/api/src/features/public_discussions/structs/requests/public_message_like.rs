use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct DeletePublicMessageLikeParams {
    pub message_id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct PublicMessageLikeCreateRequest {
    pub message_id: Uuid,
}
