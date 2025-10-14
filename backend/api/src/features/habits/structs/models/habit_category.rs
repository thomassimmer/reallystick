use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;


#[derive(Debug, Deserialize, Serialize, Clone, FromRow)]
pub struct HabitCategory {
    pub id: Uuid,
    pub name: String,
    pub icon: String,
    pub created_at: DateTime<Utc>,
}


#[derive(Serialize, Debug, Deserialize, Clone)]
pub struct HabitCategoryData {
    pub id: Uuid,
    pub name: String,
    pub icon: String,
}

impl HabitCategory {
    pub fn to_habit_category_data(&self) -> HabitCategoryData {
        HabitCategoryData {
            id: self.id,
            name: self.name.to_owned(),
            icon: self.icon.to_owned(),
        }
    }
}
