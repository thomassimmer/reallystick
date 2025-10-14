use std::collections::HashSet;

use serde::{Deserialize, Serialize};
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
pub struct GetMultipleChallengesDailyTrackingsRequest {
    pub challenge_ids: Vec<Uuid>,
}

#[derive(Deserialize, Serialize)]
pub struct ChallengeDailyTrackingUpdateRequest {
    pub day_of_program: i32,
    pub habit_id: Uuid,
    pub quantity_per_set: f64,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
    pub weight: i32,
    pub weight_unit_id: Uuid,
    pub note: Option<String>,
    pub days_to_repeat_on: HashSet<i32>,
    pub order_in_day: i32,
}

#[derive(Deserialize, Serialize)]
pub struct ChallengeDailyTrackingCreateRequest {
    pub challenge_id: Uuid,
    pub habit_id: Uuid,
    pub day_of_program: i32,
    pub quantity_per_set: f64,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
    pub weight: i32,
    pub weight_unit_id: Uuid,
    pub days_to_repeat_on: HashSet<i32>,
    pub note: Option<String>,
    pub order_in_day: i32,
}
