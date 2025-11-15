// Token service - handles JWT token generation and validation

use actix_web::web::Data;
use chrono::{DateTime, Utc};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use redis::{AsyncCommands, Client};
use serde_json::json;
use sha2::{Digest, Sha256};
use uuid::Uuid;

use crate::core::helpers::mock_now::now;
use crate::core::structs::redis_messages::UserTokenUpdatedEvent;
use crate::features::auth::domain::entities::{Claims, UserToken};
use crate::features::profile::domain::entities::User;

#[derive(Clone)]
pub struct TokenService {
    redis_client: Data<Client>,
}

impl TokenService {
    pub fn new(redis_client: Data<Client>) -> Self {
        Self { redis_client }
    }

    pub fn hash_token(token: &str) -> String {
        let mut hasher = Sha256::new();
        hasher.update(token);
        format!("{:X}", hasher.finalize())
    }

    pub fn generate_access_token(
        &self,
        secret_key: &[u8],
        jti: Uuid,
        user_id: Uuid,
        is_admin: bool,
        username: String,
    ) -> (String, DateTime<Utc>) {
        let access_token_expires_at = now()
            .checked_add_signed(chrono::Duration::minutes(15))
            .expect("invalid timestamp");

        let access_claims = Claims {
            exp: access_token_expires_at.timestamp(),
            jti,
            user_id,
            is_admin,
            username,
        };

        let access_token = encode(
            &Header::default(),
            &access_claims,
            &EncodingKey::from_secret(secret_key),
        )
        .expect("Token creation failed");

        (access_token, access_token_expires_at)
    }

    pub fn generate_refresh_token(
        &self,
        secret_key: &[u8],
        jti: Uuid,
        user_id: Uuid,
        is_admin: bool,
        username: String,
    ) -> (String, DateTime<Utc>) {
        let refresh_token_expires_at = now()
            .checked_add_signed(chrono::Duration::days(7))
            .expect("invalid timestamp");

        let refresh_claims = Claims {
            exp: refresh_token_expires_at.timestamp(),
            jti,
            user_id,
            is_admin,
            username,
        };

        let refresh_token = encode(
            &Header::default(),
            &refresh_claims,
            &EncodingKey::from_secret(secret_key),
        )
        .expect("Token creation failed");

        (refresh_token, refresh_token_expires_at)
    }

    pub async fn publish_token_updated_event(
        &self,
        token: UserToken,
        user: User,
    ) -> Result<(), String> {
        match self
            .redis_client
            .get_ref()
            .get_multiplexed_async_connection()
            .await
        {
            Ok(mut con) => {
                let result: Result<(), redis::RedisError> = con
                    .publish(
                        "user_token_updated",
                        json!(UserTokenUpdatedEvent { token, user }).to_string(),
                    )
                    .await;
                result.map_err(|e| format!("Redis publish error: {}", e))
            }
            Err(e) => Err(format!("Redis connection error: {}", e)),
        }
    }

    pub async fn publish_token_removed_event(
        &self,
        token_id: Uuid,
        user_id: Uuid,
    ) -> Result<(), String> {
        use crate::core::structs::redis_messages::UserTokenRemovedEvent;
        match self
            .redis_client
            .get_ref()
            .get_multiplexed_async_connection()
            .await
        {
            Ok(mut con) => {
                let result: Result<(), redis::RedisError> = con
                    .publish(
                        "user_token_removed",
                        json!(UserTokenRemovedEvent { token_id, user_id }).to_string(),
                    )
                    .await;
                result.map_err(|e| format!("Redis publish error: {}", e))
            }
            Err(e) => Err(format!("Redis connection error: {}", e)),
        }
    }

    pub fn validate_token(&self, token: &str, secret_key: &[u8]) -> Result<Claims, String> {
        let validation = Validation::default();
        let token_data =
            decode::<Claims>(token, &DecodingKey::from_secret(secret_key), &validation)
                .map_err(|e| format!("Token validation error: {}", e))?;

        Ok(token_data.claims)
    }

    pub fn retrieve_claims_from_request(
        &self,
        auth_header: Option<&str>,
        secret_key: &[u8],
    ) -> Result<Claims, String> {
        let auth_header = auth_header.ok_or_else(|| "Missing authorization header".to_string())?;

        let token = auth_header
            .strip_prefix("Bearer ")
            .ok_or_else(|| "Invalid authorization header format".to_string())?;

        self.validate_token(token, secret_key)
    }

    // Static method for validation without needing Redis client
    pub fn validate_token_static(token: &str, secret_key: &[u8]) -> Result<Claims, String> {
        let validation = Validation::default();
        let token_data =
            decode::<Claims>(token, &DecodingKey::from_secret(secret_key), &validation)
                .map_err(|e| format!("Token validation error: {}", e))?;

        Ok(token_data.claims)
    }

    pub fn retrieve_claims_from_request_static(
        auth_header: Option<&str>,
        secret_key: &[u8],
    ) -> Result<Claims, String> {
        let auth_header = auth_header.ok_or_else(|| "Missing authorization header".to_string())?;

        let token = auth_header
            .strip_prefix("Bearer ")
            .ok_or_else(|| "Invalid authorization header format".to_string())?;

        Self::validate_token_static(token, secret_key)
    }
}
