use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct GenericResponse {
    pub code: String,
    pub message: String,
}

#[derive(Serialize, Deserialize)]
pub struct StatisticsResponse {
    pub code: String,
    pub user_count: i64,
    pub user_token_count: i64,
    pub unit_count: i64,
    pub habit_category_count: i64,
    pub habit_count: i64,
    pub challenge_count: i64,
    pub habit_participation_count: i64,
    pub challenge_participation_count: i64,
    pub habit_daily_tracking_count: i64,
    pub challenge_daily_tracking_count: i64,
    pub notification_count: i64,
    pub private_discussion_count: i64,
    pub private_message_count: i64,
    pub public_message_count: i64,
    pub public_message_like_count: i64,
    pub public_message_report_count: i64,
    pub active_socket_count: i64,
}
