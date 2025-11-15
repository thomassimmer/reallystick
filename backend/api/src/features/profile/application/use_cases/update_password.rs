// Update password use case - updates password with current password verification

use crate::core::constants::errors::AppError;
use crate::features::auth::infrastructure::services::password_service::PasswordService;
use crate::features::profile::domain::entities::User;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use argon2::{
    password_hash::{rand_core::OsRng, PasswordHasher, SaltString},
    Argon2,
};

pub struct UpdatePasswordUseCase {
    user_repo: UserRepositoryImpl,
    _password_service: PasswordService,
}

impl UpdatePasswordUseCase {
    pub fn new(user_repo: UserRepositoryImpl) -> Self {
        let password_service = PasswordService::new();
        Self {
            user_repo,
            _password_service: password_service,
        }
    }

    pub async fn execute(
        &self,
        user: &mut User,
        current_password: String,
        new_password: String,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify current password
        let password_service = PasswordService::new();
        if !password_service.is_valid(user, &current_password) {
            return Err(AppError::InvalidUsernameOrPassword);
        }

        // Validate new password
        if let Some(error) = password_service.validate(&new_password) {
            return Err(error);
        }

        // Hash the new password
        let salt = SaltString::generate(&mut OsRng);
        let argon2 = Argon2::default();
        let password_hash = argon2
            .hash_password(new_password.as_bytes(), &salt)
            .map_err(|_| AppError::PasswordHash)?
            .to_string();

        // Update user
        user.password = password_hash;
        user.password_is_expired = false;

        self.user_repo
            .update_with_executor(user, &mut **transaction)
            .await
            .map_err(|_| AppError::UserUpdate)?;

        Ok(())
    }
}
