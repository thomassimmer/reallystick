use std::{collections::HashMap, sync::Arc};

use tokio::sync::RwLock;
use uuid::Uuid;

use crate::features::{auth::structs::models::UserToken, profile::structs::models::User};

#[derive(Default, Clone, Debug)]
pub struct UserWithUserTokens {
    pub user: User,
    pub tokens: HashMap<Uuid, UserToken>, // key is user_token's id
}

#[derive(Default, Clone)]
pub struct UsersData {
    data: Arc<RwLock<HashMap<Uuid, UserWithUserTokens>>>, // key is user's id
}

impl UsersData {
    pub async fn insert(&self, user: User, tokens: Vec<UserToken>) -> UserWithUserTokens {
        let value = UserWithUserTokens {
            user: user.clone(),
            tokens: tokens.iter().map(|t| (t.id, t.clone())).collect(),
        };
        self.data.write().await.insert(user.id, value.clone());

        value
    }

    pub async fn update_user(&self, user: User) {
        match self.data.write().await.get_mut(&user.id) {
            Some(user_with_tokens) => {
                user_with_tokens.user = user;
            }
            None => {}
        }
    }

    pub async fn update_user_token(&self, user: User, token: UserToken) {
        let user_id = user.id;
        let user_with_user_tokens = match self.data.read().await.get(&user_id).cloned() {
            Some(mut user_with_user_tokens) => {
                user_with_user_tokens.tokens.insert(token.id, token.clone());
                user_with_user_tokens
            }
            None => UserWithUserTokens {
                user,
                tokens: HashMap::from([(token.id, token)]),
            },
        };

        self.data
            .write()
            .await
            .insert(user_id, user_with_user_tokens);
    }

    pub async fn remove_user_token(&self, user_id: Uuid, token_id: Uuid) {
        let user_with_user_tokens = match self.data.read().await.get(&user_id).cloned() {
            Some(mut user_with_user_tokens) => {
                user_with_user_tokens.tokens.remove(&token_id);
                user_with_user_tokens
            }
            None => return,
        };

        self.data
            .write()
            .await
            .insert(user_id, user_with_user_tokens);
    }

    pub async fn remove_user(&self, user_id: Uuid) {
        self.data.write().await.remove(&user_id);
    }

    pub async fn get_value_for_key(&self, user_id: Uuid) -> Option<UserWithUserTokens> {
        self.data.read().await.get(&user_id).cloned()
    }
}
