// Refresh token use case - validates refresh token and generates new tokens

use crate::core::helpers::mock_now::now;
use uuid::Uuid;

use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::token_service::TokenService;
use crate::features::profile::domain::entities::{ParsedDeviceInfo, User};

pub struct RefreshTokenUseCase {
    token_repo: UserTokenRepositoryImpl,
    token_service: TokenService,
}

impl RefreshTokenUseCase {
    pub fn new(token_repo: UserTokenRepositoryImpl, token_service: TokenService) -> Self {
        Self {
            token_repo,
            token_service,
        }
    }

    pub async fn execute(
        &self,
        refresh_token: String,
        secret_key: &[u8],
        user: User,
        parsed_device_info: ParsedDeviceInfo,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(String, String, Uuid), String> {
        // Validate refresh token
        let claims = self
            .token_service
            .validate_token(&refresh_token, secret_key)
            .map_err(|e| format!("Invalid refresh token: {}", e))?;

        // Check if token exists and is not expired
        let stored_token = sqlx::query_scalar!(
            r#"
            SELECT expires_at
            FROM user_tokens
            WHERE token_id = $1
            "#,
            claims.jti
        )
        .fetch_optional(&mut **transaction)
        .await
        .map_err(|e| format!("Failed to check token: {}", e))?;

        match stored_token {
            Some(expires_at) => {
                if now() > expires_at {
                    // Token expired - delete it and publish removal event
                    self.token_repo
                        .delete_by_token_id_with_executor(claims.jti, &mut **transaction)
                        .await
                        .map_err(|e| format!("Failed to delete expired token: {}", e))?;

                    // Publish token removal event (non-blocking)
                    let token_service_clone = self.token_service.clone();
                    let jti_clone = claims.jti;
                    let user_id_clone = claims.user_id;
                    tokio::spawn(async move {
                        if let Err(e) = token_service_clone
                            .publish_token_removed_event(jti_clone, user_id_clone)
                            .await
                        {
                            tracing::error!(
                                "Failed to publish token removal event (non-critical): {}",
                                e
                            );
                        }
                    });

                    return Err("REFRESH_TOKEN_EXPIRED".to_string());
                }
            }
            None => {
                return Err("Invalid refresh token".to_string());
            }
        }

        // Delete old token
        self.token_repo
            .delete_by_token_id_with_executor(claims.jti, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to delete old token: {}", e))?;

        // Publish token removal event (non-blocking)
        let token_service_clone = self.token_service.clone();
        let jti_clone = claims.jti;
        let user_id_clone = claims.user_id;
        tokio::spawn(async move {
            if let Err(e) = token_service_clone
                .publish_token_removed_event(jti_clone, user_id_clone)
                .await
            {
                tracing::error!(
                    "Failed to publish token removal event (non-critical): {}",
                    e
                );
            }
        });

        // Generate new tokens
        let new_jti = Uuid::new_v4();
        let (access_token, _) = self.token_service.generate_access_token(
            secret_key,
            new_jti,
            user.id,
            user.is_admin,
            user.username.clone(),
        );
        let (new_refresh_token, refresh_token_expires_at) =
            self.token_service.generate_refresh_token(
                secret_key,
                new_jti,
                user.id,
                user.is_admin,
                user.username.clone(),
            );

        // Save new token
        let new_token = crate::features::auth::domain::entities::UserToken {
            id: Uuid::new_v4(),
            user_id: user.id,
            token_id: new_jti,
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
            .map_err(|e| format!("Failed to save new token: {}", e))?;

        // Publish token updated event (non-blocking)
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

        Ok((access_token, new_refresh_token, new_jti))
    }
}
