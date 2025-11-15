use serde::{Deserialize, Serialize};

use crate::features::challenges::domain::entities::challenge_participation::ChallengeParticipationData;

#[derive(Serialize, Deserialize)]
pub struct ChallengeParticipationResponse {
    pub code: String,
    pub challenge_participation: Option<ChallengeParticipationData>,
}

#[derive(Serialize, Deserialize)]
pub struct ChallengeParticipationsResponse {
    pub code: String,
    pub challenge_participations: Vec<ChallengeParticipationData>,
}
