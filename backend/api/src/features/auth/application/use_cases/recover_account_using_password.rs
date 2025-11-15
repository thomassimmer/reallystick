// Recover account using password use case - recovers account with password + recovery code

use crate::core::constants::errors::AppError;
use crate::features::auth::infrastructure::repositories::recovery_code_repository::RecoveryCodeRepositoryImpl;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::password_service::PasswordService;
use crate::features::profile::domain::entities::User;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;

pub struct RecoverAccountUsingPasswordUseCase {
    user_repo: UserRepositoryImpl,
    recovery_code_repo: RecoveryCodeRepositoryImpl,
    token_repo: UserTokenRepositoryImpl,
    password_service: PasswordService,
}

impl RecoverAccountUsingPasswordUseCase {
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
        password: String,
        recovery_code: String,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<User, AppError> {
        let username_lower = username.to_lowercase();

        // Get user by username
        let mut user = self
            .user_repo
            .get_by_username_with_executor(&username_lower, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::InvalidUsernameOrPasswordOrRecoveryCode)?;

        // Check if user is deleted
        if user.is_deleted {
            return Err(AppError::UserHasBeenDeleted);
        }

        // 2FA should be enabled
        if !user.otp_verified {
            return Err(AppError::TwoFactorAuthenticationNotEnabled);
        }

        // Check password
        if !self.password_service.is_valid(&user, &password) {
            return Err(AppError::InvalidUsernameOrPasswordOrRecoveryCode);
        }

        // Get recovery code
        let recovery_code_entity = self
            .recovery_code_repo
            .get_by_user_id_with_executor(user.id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::InvalidUsernameOrPasswordOrRecoveryCode)?;

        // Verify recovery code
        if !self
            .password_service
            .verify_recovery_code(&recovery_code_entity.recovery_code, &recovery_code)
        {
            return Err(AppError::InvalidUsernameOrPasswordOrRecoveryCode);
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

        // Disable OTP
        user.otp_verified = false;
        user.otp_auth_url = None;
        user.otp_base32 = None;

        // Update user
        self.user_repo
            .update_with_executor(&user, &mut **transaction)
            .await
            .map_err(|_| AppError::UserUpdate)?;

        Ok(user)
    }
}
