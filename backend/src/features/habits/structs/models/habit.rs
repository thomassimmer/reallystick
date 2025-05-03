use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;

pub const HABIT_DESCRIPTION_MAX_LENGTH: usize = 2_000;

#[derive(Debug, Deserialize, Serialize, Clone, FromRow)]
pub struct Habit {
    pub id: Uuid,
    pub name: String,
    pub category_id: Uuid,
    pub reviewed: bool,
    pub description: String,
    pub icon: String,
    pub created_at: DateTime<Utc>,
    pub unit_ids: String,
}

#[derive(Serialize, Debug, Deserialize, Clone)]
pub struct HabitData {
    pub id: Uuid,
    pub name: String,
    pub category_id: Uuid,
    pub reviewed: bool,
    pub description: String,
    pub icon: String,
    pub unit_ids: String,
}

impl Habit {
    pub fn to_habit_data(&self) -> HabitData {
        HabitData {
            id: self.id,
            name: self.name.to_owned(),
            category_id: self.category_id,
            reviewed: self.reviewed,
            description: self.description.to_owned(),
            icon: self.icon.to_owned(),
            unit_ids: self.unit_ids.to_owned(),
        }
    }
}
