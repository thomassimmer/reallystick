use serde::{Deserialize, Serialize};

use crate::features::habits::structs::models::habit_participation::HabitParticipationData;

#[derive(Serialize, Deserialize)]
pub struct HabitParticipationResponse {
    pub code: String,
    pub habit_participation: Option<HabitParticipationData>,
}

#[derive(Serialize, Deserialize)]
pub struct HabitParticipationsResponse {
    pub code: String,
    pub habit_participations: Vec<HabitParticipationData>,
}
