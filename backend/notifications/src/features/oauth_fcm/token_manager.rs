use std::fmt::Debug;
use std::io::Read;
use std::time::Duration;
use std::time::Instant;
use std::time::SystemTime;

use jsonwebtoken::encode;
use jsonwebtoken::EncodingKey;
use jsonwebtoken::Header;
use reqwest::Client;
use serde::Deserialize;
use serde_json::json;
use tracing::debug;
use tracing::info;
use tracing::instrument;

use crate::features::oauth_fcm::error::FcmError;
use crate::features::oauth_fcm::error::NetworkError;
use crate::features::oauth_fcm::error::ResultMapError;

/// A thread-safe, shared reference to a `TokenManager`.
///
/// Recommended, if the `TokenManager` is accessed from multiple threads.
/// A helper function for creating a `SharedTokenManager` can be found in
/// [`lib.rs`](../lib.rs).
pub type SharedTokenManager = std::sync::Arc<tokio::sync::Mutex<TokenManager>>;

/// A manager for handling OAuth tokens.
///
/// This struct is responsible for caching an internally lazily created OAuth
/// token. Every time you get the token, it checks if it is expired and creates
/// a new one if necessary. Each token is valid for one hour (the maximum
/// provided by Google).
pub struct TokenManager {
    token: Option<String>,
    expires_at: Option<Instant>,
    service_account_key: ServiceAccountKey,
}

#[derive(Deserialize, Debug)]
struct ServiceAccountKey {
    private_key: String,
    client_email: String,
    private_key_id: String,
}

impl TokenManager {
    /// Creates a new `TokenManager`.
    ///
    /// The recommended way to crate a `TokenManager` is to use the
    /// `create_shared_token_manager` function in [`lib.rs`](../lib.rs).
    ///
    /// # Arguments
    ///
    /// * `google_credentials_location` - A string slice that holds the path to
    ///   the Google credentials JSON file.
    ///
    /// # Errors
    ///
    /// This function will return an error if the Google credentials could not
    /// be read or parsed.
    #[instrument(level = "info", skip_all)]
    pub fn new<T: Read + Debug>(credentials: T) -> Result<Self, FcmError> {
        info!("Creating new TokenManager");

        let service_account_key = serde_json::from_reader(credentials)?;

        Ok(Self {
            token: None,
            expires_at: None,
            service_account_key,
        })
    }

    /// Returns the current OAuth token.
    ///
    /// This function checks if the current token is expired and refreshes it if
    /// necessary. Users normally only need this function to get the token,
    /// as it handles the token expiration internally.
    ///
    /// # Errors
    ///
    /// This function will return an error if the token could not be refreshed.
    #[instrument(level = "debug", skip(self))]
    pub async fn get_token(&mut self) -> Result<String, FcmError> {
        if let Some(token) = &self.token {
            if !self.is_token_expired() {
                debug!("Using cached token");
                return Ok(token.clone());
            }
        }

        debug!("Refreshing token");
        self.refresh_token().await
    }

    /// Checks if the current OAuth token is expired.
    ///
    /// This function is used internally by `get_token` and is not typically
    /// needed by users.
    #[instrument(level = "debug", skip(self))]
    pub fn is_token_expired(&self) -> bool {
        self.expires_at.is_none_or(|expires_at| {
            let expired = expires_at <= Instant::now();
            debug!("Token expired: {}", expired);
            expired
        })
    }

    /// Refreshes the current OAuth token.
    ///
    /// This function is used internally by `get_token` and is not typically
    /// needed by users.
    ///
    /// # Errors
    ///
    /// This function will return an error if the token could not be refreshed.
    #[instrument(level = "info", skip(self))]
    pub async fn refresh_token(&mut self) -> Result<String, FcmError> {
        info!("Refreshing token");
        self.refresh_token_with_url("https://oauth2.googleapis.com/token")
            .await
    }

    /// Refreshes the current OAuth token with a custom auth server URL.
    ///
    /// This function exists for testing purposes and is not typically needed by
    /// users.
    ///
    /// # Arguments
    ///
    /// * `auth_server_url` - A string slice that holds the custom auth server
    ///   URL.
    ///
    /// # Errors
    ///
    /// This function will return an error if the token could not be refreshed.
    #[instrument(level = "info", skip(self))]
    pub async fn refresh_token_with_url(
        &mut self,
        auth_server_url: &str,
    ) -> Result<String, FcmError> {
        info!("Refreshing token with URL: {}", auth_server_url);
        let signed_jwt = create_signed_jwt(&self.service_account_key)?;
        let access_token_response = get_access_token(&signed_jwt, auth_server_url).await?;

        let new_token = access_token_response.access_token;
        self.token = Some(new_token.clone());
        self.expires_at =
            Some(Instant::now() + Duration::from_secs(access_token_response.expires_in));

        info!("Token refreshed successfully");
        Ok(new_token)
    }
}

#[instrument(level = "debug")]
fn create_signed_jwt(service_account_key: &ServiceAccountKey) -> Result<String, FcmError> {
    debug!("Creating signed JWT");
    let mut header = Header::new(jsonwebtoken::Algorithm::RS256);
    header.kid = Some(service_account_key.private_key_id.clone());

    let now = SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .expect("Clock moved backwards! The time is before UNIX EPOCH, this should not happen!")
        .as_secs();

    let claims = json!({
        "iss": service_account_key.client_email,
        "scope": "https://www.googleapis.com/auth/firebase.messaging",
        "aud": "https://oauth2.googleapis.com/token",
        "exp": now + 3600,
        "iat": now
    });

    let encoding_key = EncodingKey::from_rsa_pem(service_account_key.private_key.as_bytes())?;
    let signed_jwt = encode(&header, &claims, &encoding_key).map_err(FcmError::JwtEncodeError)?;
    debug!("Signed JWT created");
    Ok(signed_jwt)
}

#[derive(Deserialize)]
struct AccessTokenResponse {
    access_token: String,
    expires_in: u64,
}

#[instrument(level = "debug")]
async fn get_access_token(
    signed_jwt: &str,
    auth_url: &str,
) -> Result<AccessTokenResponse, FcmError> {
    debug!("Getting access token from: {}", auth_url);
    let client = Client::new();
    let params = [
        ("grant_type", "urn:ietf:params:oauth:grant-type:jwt-bearer"),
        ("assertion", signed_jwt),
    ];

    let response = client
        .post(auth_url)
        .form(&params)
        .send()
        .await
        .map_err(NetworkError::SendRequestError)
        .map_oauth_err()?;

    debug!("Response status: {}", response.status());

    let access_token_response = response
        .json::<AccessTokenResponse>()
        .await
        .map_err(NetworkError::ResponseError)
        .map_oauth_err()?;

    debug!("Access token obtained");
    Ok(access_token_response)
}

impl Debug for TokenManager {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("TokenManager")
            .field("token", &("[REDACTED]".to_string()))
            .field("service_account_key", &("[REDACTED]".to_string()))
            .field("expires_at", &self.expires_at)
            .finish()
    }
}

pub fn create_shared_token_manager<T: Read + Debug>(
    credentials: T,
) -> Result<SharedTokenManager, FcmError> {
    info!("Creating shared token manager");
    let manager = TokenManager::new(credentials)?;
    Ok(std::sync::Arc::new(tokio::sync::Mutex::new(manager)))
}
