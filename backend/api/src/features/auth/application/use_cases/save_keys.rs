// Save keys use case - saves user's public/private keys

use crate::features::profile::application::use_cases::update_user_keys::UpdateUserKeysUseCase;
use crate::features::profile::domain::entities::User;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;

pub struct SaveKeysUseCase {
    update_user_keys_use_case: UpdateUserKeysUseCase,
}

impl SaveKeysUseCase {
    pub fn new(user_repo: UserRepositoryImpl) -> Self {
        let update_user_keys_use_case = UpdateUserKeysUseCase::new(user_repo);
        Self {
            update_user_keys_use_case,
        }
    }

    pub async fn execute(
        &self,
        user: &User,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), String> {
        self.update_user_keys_use_case
            .execute(user, transaction)
            .await
    }
}
