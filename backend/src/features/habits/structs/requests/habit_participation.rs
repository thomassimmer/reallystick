use serde::Deserialize;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct GetHabitParticipationParams {
    pub habit_participation_id: Uuid,
}

#[derive(Deserialize)]
pub struct UpdateHabitParticipationParams {
    pub habit_participation_id: Uuid,
}

#[derive(Deserialize)]
pub struct HabitParticipationUpdateRequest {
    pub color: String,
    pub to_gain: bool,
}

#[derive(Deserialize)]
pub struct HabitParticipationCreateRequest {
    pub habit_id: uuid::Uuid,
    pub color: String,
    pub to_gain: bool,
}
