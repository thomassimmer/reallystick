// Verify OTP use case - verifies OTP code and marks user as verified

use crate::core::constants::errors::AppError;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use totp_rs::{Algorithm, Secret, TOTP};
use uuid::Uuid;

pub struct VerifyOtpUseCase {
    user_repo: UserRepositoryImpl,
}

impl VerifyOtpUseCase {
    pub fn new(user_repo: UserRepositoryImpl) -> Self {
        Self { user_repo }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        code: String,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Get user
        let mut user = self
            .user_repo
            .get_by_id_with_executor(user_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::UserNotFound)?;

        // Get OTP secret
        let otp_base32 = user
            .otp_base32
            .clone()
            .ok_or(AppError::TwoFactorAuthenticationNotEnabled)?;

        // Create TOTP instance
        let totp = TOTP::new(
            Algorithm::SHA1,
            6,
            1,
            30,
            Secret::Encoded(otp_base32).to_bytes().unwrap(),
        )
        .map_err(|_| AppError::DatabaseQuery)?;

        // Verify code
        let is_valid = totp
            .check_current(&code)
            .map_err(|_| AppError::InvalidOneTimePassword)?;

        if !is_valid {
            return Err(AppError::InvalidOneTimePassword);
        }

        // Mark as verified
        user.otp_verified = true;

        // Update user
        self.user_repo
            .update_with_executor(&user, &mut **transaction)
            .await
            .map_err(|_| AppError::UserUpdate)?;

        Ok(())
    }
}
