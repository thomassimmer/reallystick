// Generate tokens use case - creates access and refresh tokens for a user

use uuid::Uuid;

use crate::features::auth::domain::entities::UserToken;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::token_service::TokenService;
use crate::features::profile::domain::entities::{ParsedDeviceInfo, User};

pub struct GenerateTokensUseCase {
    token_repo: UserTokenRepositoryImpl,
    token_service: TokenService,
}

impl GenerateTokensUseCase {
    pub fn new(token_repo: UserTokenRepositoryImpl, token_service: TokenService) -> Self {
        Self {
            token_repo,
            token_service,
        }
    }

    pub async fn execute(
        &self,
        secret_key: &[u8],
        user: User,
        parsed_device_info: ParsedDeviceInfo,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(String, String), String> {
        let jti = Uuid::new_v4();

        // Generate tokens
        let (access_token, _) = self.token_service.generate_access_token(
            secret_key,
            jti,
            user.id,
            user.is_admin,
            user.username.clone(),
        );
        let (refresh_token, refresh_token_expires_at) = self.token_service.generate_refresh_token(
            secret_key,
            jti,
            user.id,
            user.is_admin,
            user.username.clone(),
        );

        // Save token to database
        let new_token = UserToken {
            id: Uuid::new_v4(),
            user_id: user.id,
            token_id: jti,
            expires_at: refresh_token_expires_at,
            os: parsed_device_info.os,
            is_mobile: parsed_device_info.is_mobile,
            browser: parsed_device_info.browser,
            app_version: parsed_device_info.app_version,
            model: parsed_device_info.model,
            fcm_token: None,
        };

        self.token_repo
            .create_with_executor(&new_token, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to save token: {}", e))?;

        // Publish token updated event (non-blocking, errors are logged but don't fail the request)
        // This happens inside the transaction, but Redis failures won't cause rollback
        // since we're not awaiting the result in a way that would fail the transaction
        let token_service_clone = self.token_service.clone();
        let new_token_clone = new_token.clone();
        let user_clone = user.clone();
        tokio::spawn(async move {
            if let Err(e) = token_service_clone
                .publish_token_updated_event(new_token_clone, user_clone)
                .await
            {
                tracing::error!("Failed to publish token event (non-critical): {}", e);
            }
        });

        Ok((access_token, refresh_token))
    }
}
