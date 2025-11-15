// Generate OTP use case - generates OTP secret and auth URL for a user

use crate::core::constants::errors::AppError;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use base32;
use rand::Rng;
use totp_rs::{Algorithm, Secret, TOTP};
use uuid::Uuid;

pub struct GenerateOtpUseCase {
    user_repo: UserRepositoryImpl,
}

impl GenerateOtpUseCase {
    pub fn new(user_repo: UserRepositoryImpl) -> Self {
        Self { user_repo }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(String, String), AppError> {
        // Get user
        let mut user = self
            .user_repo
            .get_by_id_with_executor(user_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::UserNotFound)?;

        // Generate OTP secret
        let mut rng = rand::thread_rng();
        let data_byte: [u8; 21] = rng.gen();
        let base32_string =
            base32::encode(base32::Alphabet::Rfc4648 { padding: false }, &data_byte);

        let totp = TOTP::new(
            Algorithm::SHA1,
            6,
            1,
            30,
            Secret::Encoded(base32_string).to_bytes().unwrap(),
        )
        .map_err(|_| AppError::DatabaseQuery)?;

        let otp_base32 = totp.get_secret_base32();
        let username = user.username.clone();
        let issuer = "ReallyStick";

        // Format: otpauth://totp/<issuer>:<account_name>?secret=<secret>&issuer=<issuer>
        let otp_auth_url =
            format!("otpauth://totp/{issuer}:{username}?secret={otp_base32}&issuer={issuer}");

        // Update user
        user.otp_base32 = Some(otp_base32.clone());
        user.otp_auth_url = Some(otp_auth_url.clone());
        user.otp_verified = false;

        self.user_repo
            .update_with_executor(&user, &mut **transaction)
            .await
            .map_err(|_| AppError::UserUpdate)?;

        Ok((otp_base32, otp_auth_url))
    }
}
