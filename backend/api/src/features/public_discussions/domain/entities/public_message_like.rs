use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;

#[derive(Debug, Clone, Deserialize, Serialize, FromRow)]
pub struct PublicMessageLike {
    pub id: Uuid,
    pub message_id: Uuid,
    pub user_id: Uuid,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct PublicMessageLikeData {
    pub id: Uuid,
    pub message_id: Uuid,
    pub user_id: Uuid,
    pub created_at: DateTime<Utc>,
}

impl PublicMessageLike {
    pub fn to_public_message_like_data(&self) -> PublicMessageLikeData {
        PublicMessageLikeData {
            id: self.id,
            message_id: self.message_id,
            user_id: self.user_id,
            created_at: self.created_at,
        }
    }
}
