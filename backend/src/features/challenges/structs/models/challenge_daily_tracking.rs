use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct ChallengeDailyTracking {
    pub id: Uuid,
    pub habit_id: Uuid,
    pub challenge_id: Uuid,
    pub datetime: DateTime<Utc>,
    pub created_at: DateTime<Utc>,

    pub quantity_per_set: i32,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
    pub weight: i32,
    pub weight_unit_id: Uuid,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct ChallengeDailyTrackingData {
    pub id: Uuid,
    pub habit_id: Uuid,
    pub challenge_id: Uuid,
    pub datetime: DateTime<Utc>,

    pub quantity_per_set: i32,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
    pub weight: i32,
    pub weight_unit_id: Uuid,
}

impl ChallengeDailyTracking {
    pub fn to_challenge_daily_tracking_data(&self) -> ChallengeDailyTrackingData {
        ChallengeDailyTrackingData {
            id: self.id,
            habit_id: self.habit_id,
            challenge_id: self.challenge_id,
            datetime: self.datetime,
            quantity_of_set: self.quantity_of_set,
            quantity_per_set: self.quantity_per_set,
            unit_id: self.unit_id,
            weight: self.weight,
            weight_unit_id: self.weight_unit_id,
        }
    }
}
