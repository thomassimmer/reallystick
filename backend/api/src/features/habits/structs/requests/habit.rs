use std::collections::{HashMap, HashSet};

use serde::{Deserialize, Serialize};
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

#[derive(Deserialize, Serialize)]
pub struct HabitUpdateRequest {
    pub name: HashMap<String, String>,
    pub description: HashMap<String, String>,
    pub category_id: Uuid,
    pub reviewed: bool,
    pub icon: String,
    pub unit_ids: HashSet<Uuid>,
}

#[derive(Deserialize, Serialize)]
pub struct HabitCreateRequest {
    pub name: HashMap<String, String>,
    pub description: HashMap<String, String>,
    pub category_id: Uuid,
    pub icon: String,
    pub unit_ids: HashSet<Uuid>,
}
