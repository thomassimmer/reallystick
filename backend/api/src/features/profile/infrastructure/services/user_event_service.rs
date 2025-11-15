// User event service - handles publishing user-related events to Redis

use crate::core::structs::redis_messages::UserUpdatedEvent;
use crate::features::profile::domain::entities::User;
use actix_web::web::Data;
use redis::{AsyncCommands, Client};
use serde_json::json;

pub struct UserEventService {
    redis_client: Data<Client>,
}

impl UserEventService {
    pub fn new(redis_client: Data<Client>) -> Self {
        Self { redis_client }
    }

    pub async fn publish_user_updated_event(&self, user: User) -> Result<(), String> {
        match self
            .redis_client
            .get_ref()
            .get_multiplexed_async_connection()
            .await
        {
            Ok(mut con) => {
                let event = UserUpdatedEvent { user };
                let result: Result<(), redis::RedisError> =
                    con.publish("user_updated", json!(event).to_string()).await;
                result.map_err(|e| format!("Failed to publish user_updated event: {}", e))
            }
            Err(e) => Err(format!("Failed to get Redis connection: {}", e)),
        }
    }
}
