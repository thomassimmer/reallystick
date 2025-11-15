// Disable OTP use case - disables OTP for a user

use crate::core::constants::errors::AppError;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use uuid::Uuid;

pub struct DisableOtpUseCase {
    user_repo: UserRepositoryImpl,
}

impl DisableOtpUseCase {
    pub fn new(user_repo: UserRepositoryImpl) -> Self {
        Self { user_repo }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Get user
        let mut user = self
            .user_repo
            .get_by_id_with_executor(user_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::UserNotFound)?;

        // Disable OTP
        user.otp_verified = false;
        user.otp_auth_url = None;
        user.otp_base32 = None;

        // Update user
        self.user_repo
            .update_with_executor(&user, &mut **transaction)
            .await
            .map_err(|_| AppError::UserUpdate)?;

        Ok(())
    }
}
