// Recover account using 2FA use case - recovers account with OTP code + recovery code

use crate::core::constants::errors::AppError;
use crate::features::auth::infrastructure::repositories::recovery_code_repository::RecoveryCodeRepositoryImpl;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::password_service::PasswordService;
use crate::features::profile::domain::entities::User;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use totp_rs::{Algorithm, Secret, TOTP};

pub struct RecoverAccountUsing2FAUseCase {
    user_repo: UserRepositoryImpl,
    recovery_code_repo: RecoveryCodeRepositoryImpl,
    token_repo: UserTokenRepositoryImpl,
    password_service: PasswordService,
}

impl RecoverAccountUsing2FAUseCase {
    pub fn new(
        user_repo: UserRepositoryImpl,
        recovery_code_repo: RecoveryCodeRepositoryImpl,
        token_repo: UserTokenRepositoryImpl,
    ) -> Self {
        let password_service = PasswordService::new();
        Self {
            user_repo,
            recovery_code_repo,
            token_repo,
            password_service,
        }
    }

    pub async fn execute(
        &self,
        username: String,
        otp_code: String,
        recovery_code: String,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(User, String, String), AppError> {
        let username_lower = username.to_lowercase();

        // Get user by username
        let mut user = self
            .user_repo
            .get_by_username_with_executor(&username_lower, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::InvalidUsernameOrCodeOrRecoveryCode)?;

        // Check if user is deleted
        if user.is_deleted {
            return Err(AppError::UserHasBeenDeleted);
        }

        // Check OTP is enabled
        if !user.otp_verified {
            return Err(AppError::TwoFactorAuthenticationNotEnabled);
        }

        // Verify OTP code
        let otp_base32 = user
            .otp_base32
            .clone()
            .ok_or(AppError::TwoFactorAuthenticationNotEnabled)?;

        let totp = TOTP::new(
            Algorithm::SHA1,
            6,
            1,
            30,
            Secret::Encoded(otp_base32).to_bytes().unwrap(),
        )
        .map_err(|_| AppError::DatabaseQuery)?;

        let is_valid = totp
            .check_current(&otp_code)
            .map_err(|_| AppError::InvalidOneTimePassword)?;

        if !is_valid {
            return Err(AppError::InvalidUsernameOrCodeOrRecoveryCode);
        }

        // Get recovery code
        let recovery_code_entity = self
            .recovery_code_repo
            .get_by_user_id_with_executor(user.id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::InvalidUsernameOrCodeOrRecoveryCode)?;

        // Verify recovery code
        if !self
            .password_service
            .verify_recovery_code(&recovery_code_entity.recovery_code, &recovery_code)
        {
            return Err(AppError::InvalidUsernameOrCodeOrRecoveryCode);
        }

        // Delete recovery code
        self.recovery_code_repo
            .delete_by_user_id_with_executor(user.id, &mut **transaction)
            .await
            .map_err(|_| AppError::UserUpdate)?;

        // Delete all user tokens
        self.token_repo
            .delete_by_user_id_with_executor(user.id, &mut **transaction)
            .await
            .map_err(|_| AppError::UserTokenDeletion)?;

        // Mark password as expired
        user.password_is_expired = true;

        // Update user
        self.user_repo
            .update_with_executor(&user, &mut **transaction)
            .await
            .map_err(|_| AppError::UserUpdate)?;

        Ok((
            user,
            recovery_code_entity.private_key_encrypted,
            recovery_code_entity.salt_used_to_derive_key_from_recovery_code,
        ))
    }
}
