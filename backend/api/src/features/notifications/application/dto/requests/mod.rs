use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize, Serialize)]
pub struct DeleteNotificationParams {
    pub id: Uuid,
}

#[derive(Deserialize, Serialize)]
pub struct MarkNotificationAsSeenParams {
    pub id: Uuid,
}
