use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Deserialize)]
pub struct UserUpdateRequest {
    pub locale: String,
    pub theme: String,

    pub has_seen_questions: bool,
    pub age_category: Option<String>,
    pub gender: Option<String>,
    pub continent: Option<String>,
    pub country: Option<String>,
    pub region: Option<String>,
    pub activity: Option<String>,
    pub financial_situation: Option<String>,
    pub lives_in_urban_area: Option<bool>,
    pub relationship_status: Option<String>,
    pub level_of_education: Option<String>,
    pub has_children: Option<bool>,
}

#[derive(Debug, Deserialize)]
pub struct IsOtpEnabledRequest {
    pub username: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct SetUserPasswordRequest {
    pub new_password: String,
    pub private_key_encrypted: String,
    pub salt_used_to_derive_key_from_password: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct UpdateUserPasswordRequest {
    pub current_password: String,
    pub new_password: String,
    pub private_key_encrypted: String,
    pub salt_used_to_derive_key_from_password: String,
}

#[derive(Deserialize)]
pub struct DeleteDeviceParams {
    pub token_id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct GetUserPublicDataRequest {
    pub user_ids: Vec<Uuid>,
}
