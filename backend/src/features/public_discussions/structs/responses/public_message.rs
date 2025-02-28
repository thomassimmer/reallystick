use serde::{Deserialize, Serialize};

use crate::features::public_discussions::structs::models::public_message::PublicMessageData;

#[derive(Serialize, Deserialize)]
pub struct PublicMessageResponse {
    pub code: String,
    pub message: Option<PublicMessageData>,
}

#[derive(Serialize, Deserialize)]
pub struct PublicMessagesResponse {
    pub code: String,
    pub messages: Vec<PublicMessageData>,
}
