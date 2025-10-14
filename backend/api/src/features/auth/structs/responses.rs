use serde::{Deserialize, Serialize};

#[derive(Serialize, Debug, Deserialize)]
pub struct UserSignupResponse {
    pub code: String,
    pub access_token: String,
    pub refresh_token: String,
}

#[derive(Serialize, Debug, Deserialize)]
pub struct UserLoginWhenOtpEnabledResponse {
    pub code: String,
    pub user_id: String,
    pub public_key: Option<String>,
    pub private_key_encrypted: Option<String>,
    pub salt_used_to_derive_key: Option<String>,
}

#[derive(Serialize, Debug, Deserialize)]
pub struct UserLoginResponse {
    pub code: String,
    pub access_token: String,
    pub refresh_token: String,
    pub public_key: Option<String>,
    pub private_key_encrypted: Option<String>,
    pub salt_used_to_derive_key: Option<String>,
}

#[derive(Serialize, Debug, Deserialize)]
pub struct RefreshTokenResponse {
    pub code: String,
    pub access_token: String,
    pub refresh_token: String,
}

#[derive(Serialize, Deserialize)]
pub struct GenerateOtpResponse {
    pub code: String,
    pub otp_base32: String,
    pub otp_auth_url: String,
}

#[derive(Serialize, Deserialize)]
pub struct VerifyOtpResponse {
    pub code: String,
    pub otp_verified: bool,
}

#[derive(Serialize, Deserialize)]
pub struct DisableOtpResponse {
    pub code: String,
    pub two_fa_enabled: bool,
}

#[derive(Serialize, Deserialize)]
pub struct SaveRecoveryCodeResponse {
    pub code: String,
}
