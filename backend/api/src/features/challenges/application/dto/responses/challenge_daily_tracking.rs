use serde::{Deserialize, Serialize};

use crate::features::challenges::domain::entities::challenge_daily_tracking::ChallengeDailyTrackingData;

#[derive(Serialize, Deserialize)]
pub struct ChallengeDailyTrackingResponse {
    pub code: String,
    pub challenge_daily_tracking: Option<ChallengeDailyTrackingData>,
}

#[derive(Serialize, Deserialize)]
pub struct ChallengeDailyTrackingsResponse {
    pub code: String,
    pub challenge_daily_trackings: Vec<ChallengeDailyTrackingData>,
}
