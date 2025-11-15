// Validate OTP use case - validates OTP during login

use crate::core::constants::errors::AppError;
use crate::features::profile::domain::entities::User;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use totp_rs::{Algorithm, Secret, TOTP};
use uuid::Uuid;

pub struct ValidateOtpUseCase {
    user_repo: UserRepositoryImpl,
}

impl ValidateOtpUseCase {
    pub fn new(user_repo: UserRepositoryImpl) -> Self {
        Self { user_repo }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        code: String,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<User, AppError> {
        // Get user
        let user = self
            .user_repo
            .get_by_id_with_executor(user_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::UserNotFound)?;

        // Check if OTP is enabled
        if !user.otp_verified {
            return Err(AppError::TwoFactorAuthenticationNotEnabled);
        }

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

        Ok(user)
    }
}
