use serde::{Deserialize, Serialize};

use crate::features::habits::structs::models::habit_daily_tracking::HabitDailyTrackingData;

#[derive(Serialize, Deserialize)]
pub struct HabitDailyTrackingResponse {
    pub code: String,
    pub habit_daily_tracking: Option<HabitDailyTrackingData>,
}

#[derive(Serialize, Deserialize)]
pub struct HabitDailyTrackingsResponse {
    pub code: String,
    pub habit_daily_tracking: Vec<HabitDailyTrackingData>,
}
