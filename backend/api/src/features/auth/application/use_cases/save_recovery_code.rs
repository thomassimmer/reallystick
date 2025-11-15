// Save recovery code use case

use argon2::{password_hash::SaltString, Argon2, PasswordHasher};
use rand::rngs::OsRng;
use sqlx::Postgres;
use uuid::Uuid;

use crate::features::auth::domain::entities::RecoveryCode;
use crate::features::auth::infrastructure::repositories::recovery_code_repository::RecoveryCodeRepositoryImpl;

pub struct SaveRecoveryCodeUseCase {
    recovery_code_repo: RecoveryCodeRepositoryImpl,
}

impl SaveRecoveryCodeUseCase {
    pub fn new(recovery_code_repo: RecoveryCodeRepositoryImpl) -> Self {
        Self { recovery_code_repo }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        recovery_code: String,
        private_key_encrypted: String,
        salt_used_to_derive_key_from_recovery_code: String,
        transaction: &mut sqlx::Transaction<'_, Postgres>,
    ) -> Result<(), String> {
        // Delete existing recovery code for user
        // Use &mut **transaction to reborrow the transaction
        if let Err(e) = self
            .recovery_code_repo
            .delete_by_user_id_with_executor(user_id, &mut **transaction)
            .await
        {
            return Err(format!("Failed to delete existing recovery code: {}", e));
        }

        // Hash the recovery code
        let salt = SaltString::generate(&mut OsRng);
        let argon2 = Argon2::default();
        let hashed_code = argon2
            .hash_password(recovery_code.as_bytes(), &salt)
            .map_err(|e| format!("Failed to hash recovery code: {}", e))?
            .to_string();

        // Create new recovery code
        let new_recovery_code = RecoveryCode {
            id: Uuid::new_v4(),
            user_id,
            recovery_code: hashed_code,
            private_key_encrypted,
            salt_used_to_derive_key_from_recovery_code,
        };

        // Save new recovery code - reborrow the transaction
        self.recovery_code_repo
            .create_with_executor(&new_recovery_code, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to create recovery code: {}", e))?;

        Ok(())
    }
}
