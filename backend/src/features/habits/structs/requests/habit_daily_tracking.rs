use chrono::{DateTime, Utc};

use serde::Deserialize;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetHabitDailyTrackingParams {
    pub habit_daily_tracking_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdateHabitDailyTrackingParams {
    pub habit_daily_tracking_id: Uuid,
}

#[derive(Deserialize)]
pub struct HabitDailyTrackingUpdateRequest {
    pub datetime: DateTime<Utc>,
    pub quantity_per_set: i32,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
}

#[derive(Deserialize)]
pub struct HabitDailyTrackingCreateRequest {
    pub habit_id: Uuid,
    pub datetime: DateTime<Utc>,
    pub quantity_per_set: i32,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
}
