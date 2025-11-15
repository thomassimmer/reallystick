use serde::{Deserialize, Serialize};

use crate::features::private_discussions::domain::entities::private_discussion::PrivateDiscussionData;

#[derive(Serialize, Deserialize)]
pub struct PrivateDiscussionResponse {
    pub code: String,
    pub discussion: Option<PrivateDiscussionData>,
}

#[derive(Serialize, Deserialize)]
pub struct PrivateDiscussionsResponse {
    pub code: String,
    pub discussions: Vec<PrivateDiscussionData>,
}
