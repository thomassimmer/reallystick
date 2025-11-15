use serde::{Deserialize, Serialize};

use crate::features::public_discussions::domain::entities::public_message_like::PublicMessageLikeData;

#[derive(Serialize, Deserialize)]
pub struct PublicMessageLikeResponse {
    pub code: String,
}

#[derive(Serialize, Deserialize)]
pub struct PublicMessageLikesResponse {
    pub code: String,
    pub message_likes: Vec<PublicMessageLikeData>,
}
