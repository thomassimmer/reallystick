// Login use case - authenticates user and generates tokens

use crate::features::auth::application::use_cases::generate_tokens::GenerateTokensUseCase;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::infrastructure::services::password_service::PasswordService;
use crate::features::auth::infrastructure::services::token_service::TokenService;
use crate::features::profile::domain::entities::{ParsedDeviceInfo, User};
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;

pub struct LoginUseCase {
    user_repo: UserRepositoryImpl,
    password_service: PasswordService,
    generate_tokens_use_case: GenerateTokensUseCase,
}

impl LoginUseCase {
    pub fn new(
        user_repo: UserRepositoryImpl,
        token_repo: UserTokenRepositoryImpl,
        token_service: TokenService,
    ) -> Self {
        let password_service = PasswordService::new();
        let generate_tokens_use_case = GenerateTokensUseCase::new(token_repo, token_service);
        Self {
            user_repo,
            password_service,
            generate_tokens_use_case,
        }
    }

    pub async fn execute(
        &self,
        username: String,
        password: String,
        secret_key: &[u8],
        parsed_device_info: ParsedDeviceInfo,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(User, String, String), String> {
        let username_lower = username.to_lowercase();

        // Get user by username
        let user = self
            .user_repo
            .get_by_username_with_executor(&username_lower, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to get user: {}", e))?
            .ok_or_else(|| "Invalid username or password".to_string())?;

        // Check if user is deleted
        if user.is_deleted {
            return Err("User has been deleted".to_string());
        }

        // Restore user if deleted_at is set but not marked as deleted
        if user.deleted_at.is_some() {
            self.user_repo
                .update_deleted_at_with_executor(user.id, None, &mut **transaction)
                .await
                .map_err(|e| format!("Failed to restore user: {}", e))?;
        }

        // Validate password
        if !self.password_service.is_valid(&user, &password) {
            return Err("Invalid username or password".to_string());
        }

        // Check if password is expired
        if user.password_is_expired {
            return Err("PASSWORD_MUST_BE_CHANGED".to_string());
        }

        // Check if OTP is enabled - return user info with error
        if user.otp_verified {
            return Err(format!(
                "OTP_ENABLED:{}",
                serde_json::to_string(&user).unwrap_or_default()
            ));
        }

        // Generate tokens
        let (access_token, refresh_token) = self
            .generate_tokens_use_case
            .execute(secret_key, user.clone(), parsed_device_info, transaction)
            .await
            .map_err(|e| format!("Failed to generate tokens: {}", e))?;

        Ok((user, access_token, refresh_token))
    }
}
