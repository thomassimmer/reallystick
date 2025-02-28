use chrono::{DateTime, Utc};
use serde::Deserialize;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetChallengeParticipationParams {
    pub challenge_participation_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdateChallengeParticipationParams {
    pub challenge_participation_id: Uuid,
}

#[derive(Deserialize)]
pub struct ChallengeParticipationUpdateRequest {
    pub color: String,
    pub start_date: DateTime<Utc>,
}

#[derive(Deserialize)]
pub struct ChallengeParticipationCreateRequest {
    pub challenge_id: uuid::Uuid,
    pub color: String,
    pub start_date: DateTime<Utc>,
}
