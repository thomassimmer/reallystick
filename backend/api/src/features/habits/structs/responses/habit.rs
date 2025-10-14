use serde::{Deserialize, Serialize};

use crate::features::habits::structs::models::{habit::HabitData, habit_statistics::HabitStatistics};

#[derive(Serialize, Deserialize)]
pub struct HabitResponse {
    pub code: String,
    pub habit: Option<HabitData>,
}

#[derive(Serialize, Deserialize)]
pub struct HabitsResponse {
    pub code: String,
    pub habits: Vec<HabitData>,
}

#[derive(Serialize, Deserialize)]
pub struct HabitStatisticsResponse {
    pub code: String,
    pub statistics: Vec<HabitStatistics>,
}
