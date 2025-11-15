use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct UpdatePrivateDiscussionParticipationParams {
    pub discussion_id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct PrivateDiscussionParticipationUpdateRequest {
    pub has_blocked: bool,
    pub color: String,
}
