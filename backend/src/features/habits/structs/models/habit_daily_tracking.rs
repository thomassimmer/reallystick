use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[allow(non_snake_case)]
#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct HabitDailyTracking {
    pub id: Uuid,
    pub user_id: Uuid,
    pub habit_id: Uuid,
    pub datetime: DateTime<Utc>,
    pub created_at: DateTime<Utc>,

    pub quantity_per_set: i32,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
    pub weight: i32,
    pub weight_unit_id: Uuid,
}

#[allow(non_snake_case)]
#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct HabitDailyTrackingData {
    pub id: Uuid,
    pub user_id: Uuid,
    pub habit_id: Uuid,
    pub datetime: DateTime<Utc>,

    pub quantity_per_set: i32,
    pub quantity_of_set: i32,
    pub unit_id: Uuid,
    pub weight: i32,
    pub weight_unit_id: Uuid,
}

impl HabitDailyTracking {
    pub fn to_habit_daily_tracking_data(&self) -> HabitDailyTrackingData {
        HabitDailyTrackingData {
            id: self.id,
            user_id: self.user_id,
            habit_id: self.habit_id,
            datetime: self.datetime,
            quantity_of_set: self.quantity_of_set,
            quantity_per_set: self.quantity_per_set,
            unit_id: self.unit_id,
            weight: self.weight,
            weight_unit_id: self.weight_unit_id,
        }
    }
}
