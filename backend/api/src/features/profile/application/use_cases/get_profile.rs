// Get profile use case - retrieves user profile information

use uuid::Uuid;

use crate::features::profile::domain::entities::User;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;

pub struct GetProfileUseCase {
    user_repo: UserRepositoryImpl,
}

impl GetProfileUseCase {
    pub fn new(user_repo: UserRepositoryImpl) -> Self {
        Self { user_repo }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Option<User>, String> {
        self.user_repo
            .get_by_id_with_executor(user_id, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to get user: {}", e))
    }
}
