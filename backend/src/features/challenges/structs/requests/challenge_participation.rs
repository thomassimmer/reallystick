use chrono::{DateTime, NaiveTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetChallengeParticipationParams {
    pub challenge_participation_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdateChallengeParticipationParams {
    pub challenge_participation_id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct ChallengeParticipationUpdateRequest {
    pub color: String,
    pub start_date: DateTime<Utc>,
    pub notifications_reminder_enabled: bool,
    pub reminder_time: Option<NaiveTime>, // UTC
    pub reminder_body: Option<String>,
}

#[derive(Deserialize)]
pub struct ChallengeParticipationCreateRequest {
    pub challenge_id: uuid::Uuid,
    pub color: String,
    pub start_date: DateTime<Utc>,
}
