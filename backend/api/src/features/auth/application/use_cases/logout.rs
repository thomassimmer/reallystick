// Logout use case - deletes user token

use uuid::Uuid;

use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;

pub struct LogoutUseCase {
    token_repo: UserTokenRepositoryImpl,
}

impl LogoutUseCase {
    pub fn new(token_repo: UserTokenRepositoryImpl) -> Self {
        Self { token_repo }
    }

    pub async fn execute(
        &self,
        token_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), String> {
        self.token_repo
            .delete_by_token_id_with_executor(token_id, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to delete token: {}", e))?;

        Ok(())
    }
}
