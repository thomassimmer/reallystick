use serde::{Deserialize, Serialize};

use crate::features::challenges::structs::models::{
    challenge::ChallengeData, challenge_statistics::ChallengeStatistics,
};

#[derive(Serialize, Deserialize)]
pub struct ChallengeResponse {
    pub code: String,
    pub challenge: Option<ChallengeData>,
}

#[derive(Serialize, Deserialize)]
pub struct ChallengesResponse {
    pub code: String,
    pub challenges: Vec<ChallengeData>,
}

#[derive(Serialize, Deserialize)]
pub struct ChallengeStatisticsResponse {
    pub code: String,
    pub statistics: Vec<ChallengeStatistics>,
}
