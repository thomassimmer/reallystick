// Signup use case - creates a new user account

use chrono::Utc;
use uuid::Uuid;

use crate::core::constants::errors::AppError;
use crate::features::auth::infrastructure::services::password_service::PasswordService;
use crate::features::profile::domain::entities::User;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use argon2::{
    password_hash::{rand_core::OsRng, PasswordHasher, SaltString},
    Argon2,
};

pub struct SignupUseCase {
    user_repo: UserRepositoryImpl,
    _password_service: PasswordService,
}

impl SignupUseCase {
    pub fn new(user_repo: UserRepositoryImpl) -> Self {
        let password_service = PasswordService::new();
        Self {
            user_repo,
            _password_service: password_service,
        }
    }

    pub async fn execute(
        &self,
        username: String,
        password: String,
        locale: String,
        theme: String,
        timezone: String,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<User, AppError> {
        let username_lower = username.to_lowercase();

        // Validate password
        let password_service = PasswordService::new();
        if let Some(error) = password_service.validate(&password) {
            return Err(error);
        }

        // Check if username already exists
        let existing_user = self
            .user_repo
            .get_by_username_with_executor(&username_lower, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?;

        if existing_user.is_some() {
            return Err(AppError::UserUpdate); // Using existing error variant
        }

        // Hash password
        let salt = SaltString::generate(&mut OsRng);
        let argon2 = Argon2::default();
        let password_hash = argon2
            .hash_password(password.as_bytes(), &salt)
            .map_err(|_| AppError::RecoveryCodeHashCreation)? // Using existing error variant
            .to_string();

        // Create user
        let now = Utc::now();
        let user = User {
            id: Uuid::new_v4(),
            username: username_lower,
            password: password_hash,
            locale,
            theme,
            timezone,
            is_admin: false,
            otp_verified: false,
            otp_base32: None,
            otp_auth_url: None,
            created_at: now,
            updated_at: now,
            deleted_at: None,
            is_deleted: false,
            password_is_expired: false,
            public_key: None,
            private_key_encrypted: None,
            salt_used_to_derive_key_from_password: None,
            has_seen_questions: false,
            age_category: None,
            gender: None,
            continent: None,
            country: None,
            region: None,
            activity: None,
            financial_situation: None,
            lives_in_urban_area: None,
            relationship_status: None,
            level_of_education: None,
            has_children: None,
            notifications_enabled: true,
            notifications_for_private_messages_enabled: true,
            notifications_for_public_message_liked_enabled: true,
            notifications_for_public_message_replies_enabled: true,
            notifications_user_joined_your_challenge_enabled: true,
            notifications_user_duplicated_your_challenge_enabled: true,
        };

        // Save user
        self.user_repo
            .create_with_executor(&user, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?;

        Ok(user)
    }
}
