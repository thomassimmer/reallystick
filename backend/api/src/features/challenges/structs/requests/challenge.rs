use std::collections::HashMap;

use chrono::{DateTime, Utc};
use serde::Deserialize;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetChallengeParams {
    pub challenge_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdateChallengeParams {
    pub challenge_id: Uuid,
}

#[derive(Deserialize)]
pub struct ChallengeDuplicateParams {
    pub challenge_id: Uuid,
}

#[derive(Deserialize)]
pub struct ChallengeUpdateRequest {
    pub name: HashMap<String, String>,
    pub description: HashMap<String, String>,
    pub start_date: Option<DateTime<Utc>>,
    pub icon: String,
}

#[derive(Deserialize)]
pub struct ChallengeCreateRequest {
    pub name: HashMap<String, String>,
    pub description: HashMap<String, String>,
    #[serde(default)]
    pub start_date: Option<DateTime<Utc>>,
    pub icon: String,
}
