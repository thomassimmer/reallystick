// Update user keys use case - updates user's public/private keys

use crate::features::profile::domain::entities::User;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;

pub struct UpdateUserKeysUseCase {
    user_repo: UserRepositoryImpl,
}

impl UpdateUserKeysUseCase {
    pub fn new(user_repo: UserRepositoryImpl) -> Self {
        Self { user_repo }
    }

    pub async fn execute(
        &self,
        user: &User,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), String> {
        self.user_repo
            .update_keys_with_executor(user, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to update user keys: {}", e))?;
        Ok(())
    }
}
