use actix_http::Payload;
use actix_web::{FromRequest, HttpMessage, HttpRequest};
use chrono::{DateTime, Utc};
use futures_util::future::{err, ok, Ready};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;

#[allow(non_snake_case)]
#[derive(Serialize, Debug, Deserialize)]
pub struct UserData {
    pub id: Uuid,
    pub username: String,
    pub locale: String,
    pub theme: String,

    pub otp_verified: bool,
    pub otp_base32: Option<String>,
    pub otp_auth_url: Option<String>,

    pub createdAt: DateTime<Utc>,
    pub updatedAt: DateTime<Utc>,

    pub password_is_expired: bool,

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
}

#[allow(non_snake_case)]
#[derive(Debug, Deserialize, Serialize, Clone, FromRow)]
pub struct User {
    pub id: uuid::Uuid,
    pub username: String, // lowercase
    pub password: String, // case sensitive
    pub locale: String,
    pub theme: String,

    pub otp_verified: bool,
    pub otp_base32: Option<String>,
    pub otp_auth_url: Option<String>,

    pub created_at: chrono::DateTime<chrono::Utc>,
    pub updated_at: chrono::DateTime<chrono::Utc>,

    pub recovery_codes: String, // case sensitive
    pub password_is_expired: bool,

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
}

impl User {
    pub fn to_user_data(&self) -> UserData {
        UserData {
            id: self.id,
            username: self.username.to_owned(),
            locale: self.locale.to_owned(),
            theme: self.theme.to_owned(),
            otp_auth_url: self.otp_auth_url.to_owned(),
            otp_base32: self.otp_base32.to_owned(),
            otp_verified: self.otp_verified,
            createdAt: self.created_at,
            updatedAt: self.updated_at,
            password_is_expired: self.password_is_expired,
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
        }
    }
}

impl FromRequest for User {
    type Error = actix_web::Error;
    type Future = Ready<Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, _: &mut Payload) -> Self::Future {
        match req.extensions().get::<User>() {
            Some(user) => ok(user.clone()),
            None => err(actix_web::error::ErrorBadRequest("ups...")),
        }
    }
}
