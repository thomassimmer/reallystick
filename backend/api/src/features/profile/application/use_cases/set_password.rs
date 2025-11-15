// Set password use case - sets password when it's expired

use crate::core::structs::responses::GenericResponse;
use crate::features::auth::infrastructure::services::password_service::PasswordService;
use crate::features::profile::domain::entities::User;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use argon2::{
    password_hash::{rand_core::OsRng, PasswordHasher, SaltString},
    Argon2,
};

pub struct SetPasswordUseCase {
    user_repo: UserRepositoryImpl,
    _password_service: PasswordService,
}

impl SetPasswordUseCase {
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
        new_password: String,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), GenericResponse> {
        // Check if password is expired
        if !user.password_is_expired {
            return Err(GenericResponse {
                code: "PASSWORD_NOT_EXPIRED".to_string(),
                message: "Password is not expired. You cannot set it here.".to_string(),
            });
        }

        // Validate new password
        let password_service = PasswordService::new();
        if let Some(error) = password_service.validate(&new_password) {
            return Err(GenericResponse {
                code: error.to_response().code,
                message: error.to_response().message,
            });
        }

        // Hash the new password
        let salt = SaltString::generate(&mut OsRng);
        let argon2 = Argon2::default();
        let password_hash = argon2
            .hash_password(new_password.as_bytes(), &salt)
            .map_err(|_| GenericResponse {
                code: "PASSWORD_HASH_ERROR".to_string(),
                message: "Failed to hash password.".to_string(),
            })?
            .to_string();

        // Update user
        user.password = password_hash;
        user.password_is_expired = false;

        self.user_repo
            .update_with_executor(user, &mut **transaction)
            .await
            .map_err(|_| GenericResponse {
                code: "USER_UPDATE_ERROR".to_string(),
                message: "Failed to update user.".to_string(),
            })?;

        Ok(())
    }
}
