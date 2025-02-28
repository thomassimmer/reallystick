use serde::{Deserialize, Serialize};

use crate::features::private_discussions::structs::models::private_message::PrivateMessageData;

#[derive(Serialize, Deserialize)]
pub struct PrivateMessageResponse {
    pub code: String,
    pub message: Option<PrivateMessageData>,
}

#[derive(Serialize, Deserialize)]
pub struct PrivateMessagesResponse {
    pub code: String,
    pub messages: Vec<PrivateMessageData>,
}
