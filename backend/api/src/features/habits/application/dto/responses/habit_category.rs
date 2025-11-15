use serde::{Deserialize, Serialize};

use crate::features::habits::domain::entities::habit_category::HabitCategoryData;

#[derive(Serialize, Deserialize)]
pub struct HabitCategoryResponse {
    pub code: String,
    pub habit_category: Option<HabitCategoryData>,
}

#[derive(Serialize, Deserialize)]
pub struct HabitCategoriesResponse {
    pub code: String,
    pub habit_categories: Vec<HabitCategoryData>,
}
