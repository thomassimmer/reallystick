// Profile domain entities

use actix_http::Payload;
use actix_web::{FromRequest, HttpRequest};
use chrono::{DateTime, Utc};
use futures_util::future::{ok, Ready};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;
use uuid::Uuid;

#[derive(Debug, Default, Deserialize, Serialize, Clone, FromRow)]
pub struct User {
    pub id: uuid::Uuid,
    pub username: String, // lowercase
    pub password: String, // case sensitive
    pub locale: String,
    pub theme: String,
    pub timezone: String,

    pub is_admin: bool,

    pub otp_verified: bool,
    pub otp_base32: Option<String>,
    pub otp_auth_url: Option<String>,

    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub deleted_at: Option<DateTime<Utc>>,
    pub is_deleted: bool,

    pub password_is_expired: bool,
    pub public_key: Option<String>,
    pub private_key_encrypted: Option<String>,
    pub salt_used_to_derive_key_from_password: Option<String>,

    pub has_seen_questions: bool,
    pub age_category: Option<String>,
    pub gender: Option<String>,
    pub continent: Option<String>,
    pub country: Option<String>,
    pub region: Option<String>,
    pub activity: Option<String>,
    pub financial_situation: Option<String>,
    pub lives_in_urban_area: Option<bool>,
    pub relationship_status: Option<String>,
    pub level_of_education: Option<String>,
    pub has_children: Option<bool>,

    pub notifications_enabled: bool,
    pub notifications_for_private_messages_enabled: bool,
    pub notifications_for_public_message_liked_enabled: bool,
    pub notifications_for_public_message_replies_enabled: bool,
    pub notifications_user_joined_your_challenge_enabled: bool,
    pub notifications_user_duplicated_your_challenge_enabled: bool,
}

impl User {
    pub fn to_user_public_data(&self) -> UserPublicData {
        UserPublicData {
            id: self.id,
            username: self.username.to_owned(),
            public_key: self.public_key.to_owned(),
            locale: self.locale.to_owned(),
            is_deleted: self.is_deleted,
        }
    }

    pub fn to_user_data(&self) -> UserData {
        UserData {
            id: self.id,
            username: self.username.to_owned(),
            locale: self.locale.to_owned(),
            theme: self.theme.to_owned(),
            timezone: self.timezone.to_owned(),
            is_admin: self.is_admin,
            public_key: self.public_key.to_owned(),
            private_key_encrypted: self.private_key_encrypted.to_owned(),
            salt_used_to_derive_key_from_password: self
                .salt_used_to_derive_key_from_password
                .to_owned(),
            otp_auth_url: self.otp_auth_url.to_owned(),
            otp_base32: self.otp_base32.to_owned(),
            otp_verified: self.otp_verified,
            password_is_expired: self.password_is_expired,
            has_seen_questions: self.has_seen_questions,
            age_category: self.age_category.to_owned(),
            gender: self.gender.to_owned(),
            continent: self.continent.to_owned(),
            country: self.country.to_owned(),
            region: self.region.to_owned(),
            activity: self.activity.to_owned(),
            financial_situation: self.financial_situation.to_owned(),
            lives_in_urban_area: self.lives_in_urban_area,
            relationship_status: self.relationship_status.to_owned(),
            level_of_education: self.level_of_education.to_owned(),
            has_children: self.has_children,
            notifications_enabled: self.notifications_enabled,
            notifications_for_private_messages_enabled: self
                .notifications_for_private_messages_enabled,
            notifications_for_public_message_liked_enabled: self
                .notifications_for_public_message_liked_enabled,
            notifications_for_public_message_replies_enabled: self
                .notifications_for_public_message_replies_enabled,
            notifications_user_joined_your_challenge_enabled: self
                .notifications_user_joined_your_challenge_enabled,
            notifications_user_duplicated_your_challenge_enabled: self
                .notifications_user_duplicated_your_challenge_enabled,
        }
    }
}

#[derive(Serialize, Debug, Deserialize)]
pub struct UserData {
    pub id: Uuid,
    pub username: String,
    pub locale: String,
    pub theme: String,
    pub timezone: String,

    pub is_admin: bool,

    pub otp_verified: bool,
    pub otp_base32: Option<String>,
    pub otp_auth_url: Option<String>,

    pub password_is_expired: bool,
    pub public_key: Option<String>,
    pub private_key_encrypted: Option<String>,
    pub salt_used_to_derive_key_from_password: Option<String>,

    pub has_seen_questions: bool,
    pub age_category: Option<String>,
    pub gender: Option<String>,
    pub continent: Option<String>,
    pub country: Option<String>,
    pub region: Option<String>,
    pub activity: Option<String>,
    pub financial_situation: Option<String>,
    pub lives_in_urban_area: Option<bool>,
    pub relationship_status: Option<String>,
    pub level_of_education: Option<String>,
    pub has_children: Option<bool>,

    pub notifications_enabled: bool,
    pub notifications_for_private_messages_enabled: bool,
    pub notifications_for_public_message_liked_enabled: bool,
    pub notifications_for_public_message_replies_enabled: bool,
    pub notifications_user_joined_your_challenge_enabled: bool,
    pub notifications_user_duplicated_your_challenge_enabled: bool,
}

#[derive(Serialize, Debug, Deserialize, Clone)]
pub struct UserPublicData {
    pub id: Uuid,
    pub username: String,
    pub public_key: Option<String>,
    pub locale: String,
    pub is_deleted: bool,
}

#[derive(Default, Clone)]
pub struct UserPublicDataCache {
    data: Arc<RwLock<HashMap<Uuid, UserPublicData>>>,
}

impl UserPublicDataCache {
    pub async fn update_or_insert_key(&self, key: Uuid, value: UserPublicData) {
        self.data
            .write()
            .await
            .entry(key)
            .and_modify(|v| *v = value.clone())
            .or_insert(value);
    }

    pub async fn remove_key(&self, key: Uuid) {
        self.data.write().await.remove(&key);
    }

    pub async fn get_value_for_key(&self, key: Uuid) -> Option<UserPublicData> {
        self.data.read().await.get(&key).cloned()
    }

    pub async fn insert_mutiple_keys(&self, key_value_couples: Vec<(Uuid, UserPublicData)>) {
        self.data.write().await.extend(key_value_couples);
    }

    pub async fn get_value_for_key_or_insert_it(
        &self,
        key: &Uuid,
        conn: &mut sqlx::PgConnection,
    ) -> Option<UserPublicData> {
        if let Some(r) = self.data.read().await.get(key).cloned() {
            return Some(r);
        }

        // Using repository executor method directly with the connection
        // Note: We create a dummy repository instance just to access the executor method
        // The pool is not used since we pass the executor explicitly
        use crate::features::profile::domain::entities::User;
        match sqlx::query_as!(
            User,
            r#"
            SELECT *
            FROM users
            WHERE id = $1
            "#,
            *key
        )
        .fetch_optional(conn)
        .await
        {
            Ok(Some(u)) => {
                let user_public_data = u.to_user_public_data();

                self.update_or_insert_key(*key, user_public_data.clone())
                    .await;

                Some(user_public_data)
            }
            _ => None,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParsedDeviceInfo {
    pub os: Option<String>,
    pub is_mobile: Option<bool>,
    pub browser: Option<String>,
    pub app_version: Option<String>,
    pub model: Option<String>,
}

impl FromRequest for ParsedDeviceInfo {
    type Error = actix_web::Error;
    type Future = Ready<Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, _payload: &mut Payload) -> Self::Future {
        let user_agent = req
            .headers()
            .get("x-user-agent")
            .and_then(|h| h.to_str().ok())
            .unwrap_or("")
            .to_string();

        if user_agent.is_empty() {
            return ok(ParsedDeviceInfo {
                os: None,
                is_mobile: None,
                browser: None,
                app_version: None,
                model: None,
            });
        }

        let parts: Vec<&str> = user_agent.split('|').collect();

        ok(ParsedDeviceInfo {
            os: parts.first().map(|s| s.to_string()),
            is_mobile: parts.get(1).and_then(|s| s.parse().ok()),
            browser: parts.get(2).map(|s| s.to_string()),
            app_version: parts.get(3).map(|s| s.to_string()),
            model: parts.get(4).map(|s| s.to_string()),
        })
    }
}

impl ParsedDeviceInfo {
    pub fn from_user_agent(user_agent: &str) -> Result<Self, String> {
        let mut fields = HashMap::new();

        for entry in user_agent.split("; ") {
            if let Some((key, value)) = entry.split_once('=') {
                fields.insert(key.trim(), value.trim());
            }
        }

        let parsed = ParsedDeviceInfo {
            os: fields.get("os").map(|s| s.to_string()),
            is_mobile: fields.get("isMobile").and_then(|s| s.parse::<bool>().ok()),
            browser: fields.get("browser").map(|s| s.to_string()),
            app_version: fields.get("appVersion").map(|s| s.to_string()),
            model: fields.get("model").map(|s| s.to_string()),
        };

        Ok(parsed)
    }
}
