use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;

pub const CHALLENGE_DESCRIPTION_MAX_LENGTH: usize = 2_000;

#[derive(Debug, Deserialize, Serialize, Clone, FromRow)]
pub struct Challenge {
    pub id: Uuid,
    pub name: String,
    pub description: String,
    pub start_date: Option<DateTime<Utc>>,
    pub icon: String,
    pub created_at: DateTime<Utc>,
    pub creator: Uuid,
    pub deleted: bool,
}

#[derive(Serialize, Debug, Deserialize, Clone)]
pub struct ChallengeData {
    pub id: Uuid,
    pub name: String,
    pub description: String,
    pub start_date: Option<DateTime<Utc>>,
    pub icon: String,
    pub creator: Uuid,
    pub deleted: bool,
}

impl Challenge {
    pub fn to_challenge_data(&self) -> ChallengeData {
        ChallengeData {
            id: self.id,
            name: self.name.to_owned(),
            description: self.description.to_owned(),
            start_date: self.start_date,
            icon: self.icon.to_owned(),
            creator: self.creator,
            deleted: self.deleted,
        }
    }
}
