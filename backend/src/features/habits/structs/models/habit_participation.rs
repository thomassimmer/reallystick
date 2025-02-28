use chrono::{DateTime, NaiveTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;


#[derive(Debug, Deserialize, Serialize, Clone, FromRow)]
pub struct HabitParticipation {
    pub id: Uuid,
    pub user_id: Uuid,
    pub habit_id: Uuid,
    pub color: String,
    pub to_gain: bool,
    pub created_at: DateTime<Utc>,
    pub notifications_reminder_enabled: bool,
    pub reminder_time: Option<NaiveTime>,
    pub timezone: Option<String>,
}


#[derive(Serialize, Debug, Deserialize, Clone)]
pub struct HabitParticipationData {
    pub id: Uuid,
    pub user_id: Uuid,
    pub habit_id: Uuid,
    pub color: String,
    pub to_gain: bool,
}

impl HabitParticipation {
    pub fn to_habit_participation_data(&self) -> HabitParticipationData {
        HabitParticipationData {
            id: self.id,
            user_id: self.user_id,
            habit_id: self.habit_id,
            color: self.color.to_owned(),
            to_gain: self.to_gain,
        }
    }
}
