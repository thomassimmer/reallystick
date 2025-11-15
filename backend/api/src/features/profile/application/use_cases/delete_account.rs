// Delete account use case - marks user as deleted and deletes all tokens

use crate::core::constants::errors::AppError;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use chrono::Utc;
use uuid::Uuid;

pub struct DeleteAccountUseCase {
    user_repo: UserRepositoryImpl,
    token_repo: UserTokenRepositoryImpl,
}

impl DeleteAccountUseCase {
    pub fn new(user_repo: UserRepositoryImpl, token_repo: UserTokenRepositoryImpl) -> Self {
        Self {
            user_repo,
            token_repo,
        }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Update user deleted_at
        self.user_repo
            .update_deleted_at_with_executor(user_id, Some(Utc::now()), &mut **transaction)
            .await
            .map_err(|_| AppError::UserUpdate)?;

        // Delete all user tokens
        self.token_repo
            .delete_by_user_id_with_executor(user_id, &mut **transaction)
            .await
            .map_err(|_| AppError::UserTokenDeletion)?;

        Ok(())
    }
}
