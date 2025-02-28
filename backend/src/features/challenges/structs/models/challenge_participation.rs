use chrono::{DateTime, NaiveTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;

#[derive(Debug, Deserialize, Serialize, Clone, FromRow)]
pub struct ChallengeParticipation {
    pub id: Uuid,
    pub user_id: Uuid,
    pub challenge_id: Uuid,
    pub color: String,
    pub start_date: DateTime<Utc>,
    pub created_at: DateTime<Utc>,
    pub notifications_reminder_enabled: bool,
    pub reminder_time: Option<NaiveTime>, // UTC
    pub timezone: Option<String>,
}

#[derive(Serialize, Debug, Deserialize, Clone)]
pub struct ChallengeParticipationData {
    pub id: Uuid,
    pub user_id: Uuid,
    pub challenge_id: Uuid,
    pub color: String,
    pub start_date: DateTime<Utc>,
}

impl ChallengeParticipation {
    pub fn to_challenge_participation_data(&self) -> ChallengeParticipationData {
        ChallengeParticipationData {
            id: self.id,
            user_id: self.user_id,
            challenge_id: self.challenge_id,
            color: self.color.to_owned(),
            start_date: self.start_date,
        }
    }
}
