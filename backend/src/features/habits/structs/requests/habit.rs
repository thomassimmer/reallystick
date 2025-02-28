use std::collections::{HashMap, HashSet};

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
pub struct MergeHabitsParams {
    pub habit_to_delete_id: Uuid,
    pub habit_to_merge_on_id: Uuid,
}

#[derive(Deserialize)]
pub struct HabitUpdateRequest {
    pub short_name: HashMap<String, String>,
    pub long_name: HashMap<String, String>,
    pub description: HashMap<String, String>,
    pub category_id: Uuid,
    pub reviewed: bool,
    pub icon: String,
    pub unit_ids: HashSet<Uuid>,
}

#[derive(Deserialize)]
pub struct HabitCreateRequest {
    pub short_name: HashMap<String, String>,
    pub long_name: HashMap<String, String>,
    pub description: HashMap<String, String>,
    pub category_id: Uuid,
    pub icon: String,
    pub unit_ids: HashSet<Uuid>,
}
