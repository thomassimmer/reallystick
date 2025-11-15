// Delete device use case - deletes a user token/device

use crate::core::constants::errors::AppError;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use uuid::Uuid;

pub struct DeleteDeviceUseCase {
    token_repo: UserTokenRepositoryImpl,
}

impl DeleteDeviceUseCase {
    pub fn new(token_repo: UserTokenRepositoryImpl) -> Self {
        Self { token_repo }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        token_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify token exists
        let token = self
            .token_repo
            .get_by_user_and_token_id_with_executor(user_id, token_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?;

        if token.is_none() {
            return Err(AppError::DatabaseQuery);
        }

        // Delete token
        self.token_repo
            .delete_by_token_id_with_executor(token_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?;

        Ok(())
    }
}
