// Get devices use case - gets all user tokens/devices

use crate::features::auth::domain::entities::UserToken;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use uuid::Uuid;

pub struct GetDevicesUseCase {
    token_repo: UserTokenRepositoryImpl,
}

impl GetDevicesUseCase {
    pub fn new(token_repo: UserTokenRepositoryImpl) -> Self {
        Self { token_repo }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Vec<UserToken>, String> {
        self.token_repo
            .get_by_user_id_with_executor(user_id, &mut **transaction)
            .await
            .map_err(|e| e.to_string())
    }
}
