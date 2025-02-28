use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct PrivateDiscussionParticipationResponse {
    pub code: String,
}
