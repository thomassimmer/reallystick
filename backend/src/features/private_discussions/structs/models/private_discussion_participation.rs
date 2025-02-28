use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct PrivateDiscussionParticipation {
    pub id: Uuid,
    pub user_id: Uuid,
    pub color: String,
    pub discussion_id: Uuid,
    pub created_at: DateTime<Utc>,
    pub has_blocked: bool,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct PrivateDiscussionParticipationData {
    pub id: Uuid,
    pub user_id: Uuid,
    pub color: String,
    pub discussion_id: Uuid,
    pub created_at: DateTime<Utc>,
    pub has_blocked: bool,
}

impl PrivateDiscussionParticipation {
    pub fn to_private_discussion_participation_data(&self) -> PrivateDiscussionParticipationData {
        PrivateDiscussionParticipationData {
            id: self.id,
            user_id: self.user_id,
            color: self.color.to_owned(),
            discussion_id: self.discussion_id,
            created_at: self.created_at,
            has_blocked: self.has_blocked,
        }
    }
}
