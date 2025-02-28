use chrono::{DateTime, Utc};

use serde::Deserialize;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetChallengeDailyTrackingParams {
    pub challenge_daily_tracking_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdateChallengeDailyTrackingParams {
    pub challenge_daily_tracking_id: Uuid,
}

#[derive(Deserialize)]
pub struct GetChallengeDailyTrackingsParams {
    pub challenge_id: Uuid,
}

#[derive(Deserialize)]
pub struct ChallengeDailyTrackingUpdateRequest {
    pub datetime: DateTime<Utc>,
    pub habit_id: Uuid,
    pub quantity_per_set: i32,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
    pub weight: i32,
    pub weight_unit_id: Uuid,
}

#[derive(Deserialize)]
pub struct ChallengeDailyTrackingCreateRequest {
    pub challenge_id: Uuid,
    pub habit_id: Uuid,
    pub datetime: DateTime<Utc>,
    pub quantity_per_set: i32,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
    pub weight: i32,
    pub weight_unit_id: Uuid,
}
