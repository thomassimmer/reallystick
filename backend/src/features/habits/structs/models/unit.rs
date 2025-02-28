use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;
use uuid::Uuid;

#[allow(non_snake_case)]
#[derive(Debug, Deserialize, Serialize, Clone, FromRow)]
pub struct Unit {
    pub id: Uuid,
    pub short_name: String,
    pub long_name: String,
    pub created_at: DateTime<Utc>,
}

#[allow(non_snake_case)]
#[derive(Serialize, Debug, Deserialize, Clone)]
pub struct UnitData {
    pub id: Uuid,
    pub short_name: String,
    pub long_name: String,
}

impl Unit {
    pub fn to_unit_data(&self) -> UnitData {
        UnitData {
            id: self.id,
            short_name: self.short_name.to_owned(),
            long_name: self.long_name.to_owned(),
        }
    }
}
