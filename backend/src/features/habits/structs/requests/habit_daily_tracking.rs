use chrono::NaiveDateTime;

use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetHabitDailyTrackingParams {
    pub habit_daily_tracking_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdateHabitDailyTrackingParams {
    pub habit_daily_tracking_id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct HabitDailyTrackingUpdateRequest {
    pub datetime: NaiveDateTime,
    pub quantity_per_set: i32,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
    pub weight: i32,
    pub weight_unit_id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct HabitDailyTrackingCreateRequest {
    pub habit_id: Uuid,
    pub datetime: NaiveDateTime,
    pub quantity_per_set: i32,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
    pub weight: i32,
    pub weight_unit_id: Uuid,
}
