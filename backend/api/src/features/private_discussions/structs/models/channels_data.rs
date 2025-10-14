use std::{collections::HashMap, sync::Arc};

use actix_ws::Session;
use tokio::sync::RwLock;
use uuid::Uuid;

#[derive(Default, Clone, Hash, PartialEq, Eq)]
pub struct UserIdWithUserTokenId {
    pub user_id: Uuid,
    pub token_id: Uuid,
}

#[derive(Default, Clone)]
pub struct ChannelsData {
    data: Arc<RwLock<HashMap<UserIdWithUserTokenId, HashMap<Uuid, Session>>>>, // key is user's id
}

impl ChannelsData {
    pub async fn insert(
        &self,
        user_id: Uuid,
        token_id: Uuid,
        session_uuid: Uuid,
        session: Session,
    ) {
        if let Some(existing_sessions) = self
            .data
            .write()
            .await
            .get_mut(&UserIdWithUserTokenId { user_id, token_id })
        {
            existing_sessions.insert(session_uuid, session);
            return;
        }

        self.data.write().await.insert(
            UserIdWithUserTokenId { user_id, token_id },
            HashMap::from([(session_uuid, session)]),
        );
    }

    pub async fn remove_key(&self, user_id: Uuid, token_id: Uuid, session_uuid: Uuid) {
        let can_remove_user_entry = if let Some(existing_sessions) = self
            .data
            .write()
            .await
            .get_mut(&UserIdWithUserTokenId { user_id, token_id })
        {
            existing_sessions.remove(&session_uuid);
            existing_sessions.len() == 0
        } else {
            false
        };

        if can_remove_user_entry {
            self.data
                .write()
                .await
                .remove(&UserIdWithUserTokenId { user_id, token_id });
        }
    }

    pub async fn get_value_for_key(
        &self,
        user_id: Uuid,
        token_id: Uuid,
    ) -> Option<HashMap<Uuid, Session>> {
        self.data
            .read()
            .await
            .get(&UserIdWithUserTokenId { user_id, token_id })
            .cloned()
    }

    pub async fn count_sessions(&self) -> usize {
        self.data
            .read()
            .await
            .values()
            .map(|sessions| sessions.len()) // Count sessions per user
            .sum() // Sum up total sessions
    }
}
