use redis::Client;

use crate::{
    core::structs::redis_messages::UserRemovedEvent,
    features::profile::structs::models::UserPublicDataCache,
};

pub async fn handle_redis_messages(
    redis_client: Client,
    user_public_data_cache: UserPublicDataCache,
) {
    let mut redis_conn = redis_client.get_connection().unwrap();
    let mut pub_sub = redis_conn.as_pubsub();

    pub_sub.subscribe("user_marked_as_deleted").unwrap();
    pub_sub.subscribe("user_deleted").unwrap();

    while let Ok(msg) = pub_sub.get_message() {
        let payload: String = msg.get_payload().unwrap();
        let msg_type = msg.get_channel_name();

        if msg_type == "user_marked_as_deleted" || msg_type == "user_deleted" {
            match serde_json::from_str::<UserRemovedEvent>(&payload) {
                Ok(event) => {
                    user_public_data_cache.remove_key(event.user_id).await;
                }
                _ => return,
            }
        }
    }
}
