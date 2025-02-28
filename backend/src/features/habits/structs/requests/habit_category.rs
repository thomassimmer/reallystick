use std::collections::HashMap;

use serde::Deserialize;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetHabitCategoryParams {
    pub habit_category_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdateHabitCategoryParams {
    pub habit_category_id: Uuid,
}

#[derive(Deserialize)]
pub struct HabitCategoryCreateRequest {
    pub name: HashMap<String, String>,
    pub icon: String,
}

#[derive(Deserialize)]
pub struct HabitCategoryUpdateRequest {
    pub name: HashMap<String, String>,
    pub icon: String,
}
