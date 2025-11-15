// Set FCM token use case - updates FCM token for a user token

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::UserToken;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::profile::domain::entities::User;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use uuid::Uuid;

pub struct SetFcmTokenUseCase {
    user_repo: UserRepositoryImpl,
    token_repo: UserTokenRepositoryImpl,
}

impl SetFcmTokenUseCase {
    pub fn new(user_repo: UserRepositoryImpl, token_repo: UserTokenRepositoryImpl) -> Self {
        Self {
            user_repo,
            token_repo,
        }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        token_id: Uuid,
        fcm_token: Option<String>,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(User, UserToken), AppError> {
        // Get user
        let user = self
            .user_repo
            .get_by_id_with_executor(user_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::UserNotFound)?;

        // Get token
        let mut token = self
            .token_repo
            .get_by_user_and_token_id_with_executor(user_id, token_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::UserTokenNotFound)?;

        // Update FCM token
        token.fcm_token = fcm_token;
        self.token_repo
            .update_with_executor(&token, &mut **transaction)
            .await
            .map_err(|_| AppError::UserUpdate)?;

        Ok((user, token))
    }
}
