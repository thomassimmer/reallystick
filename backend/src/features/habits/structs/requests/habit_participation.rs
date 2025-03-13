use chrono::NaiveTime;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetHabitParticipationParams {
    pub habit_participation_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdateHabitParticipationParams {
    pub habit_participation_id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct HabitParticipationUpdateRequest {
    pub color: String,
    pub to_gain: bool,
    pub notifications_reminder_enabled: bool,
    pub reminder_time: Option<NaiveTime>,
    pub reminder_body: Option<String>,
}

#[derive(Deserialize)]
pub struct HabitParticipationCreateRequest {
    pub habit_id: uuid::Uuid,
    pub color: String,
    pub to_gain: bool,
}
