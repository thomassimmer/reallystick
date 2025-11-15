use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::features::{auth::domain::entities::UserToken, profile::domain::entities::User};

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct NotificationEvent {
    pub data: String,
    pub recipient: Uuid,
    pub title: Option<String>,
    pub body: Option<String>,
    pub url: Option<String>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct UserUpdatedEvent {
    pub user: User,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct UserRemovedEvent {
    pub user_id: Uuid,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct UserTokenUpdatedEvent {
    pub user: User,
    pub token: UserToken,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct UserTokenRemovedEvent {
    pub user_id: Uuid,
    pub token_id: Uuid,
}
