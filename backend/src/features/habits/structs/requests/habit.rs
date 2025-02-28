use std::collections::HashMap;

use serde::Deserialize;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetHabitParams {
    pub habit_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdateHabitParams {
    pub habit_id: Uuid,
}

#[derive(Deserialize)]
pub struct HabitUpdateRequest {
    pub short_name: HashMap<String, String>,
    pub long_name: HashMap<String, String>,
    pub description: HashMap<String, String>,
    pub category_id: Uuid,
    pub reviewed: bool,
    pub icon: String,
}

#[derive(Deserialize)]
pub struct HabitCreateRequest {
    pub short_name: HashMap<String, String>,
    pub long_name: HashMap<String, String>,
    pub description: HashMap<String, String>,
    pub category_id: Uuid,
    pub icon: String,
}
