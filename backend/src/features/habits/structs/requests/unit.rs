use std::collections::HashMap;

use serde::Deserialize;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct UpdateUnitParams {
    pub unit_id: Uuid,
}

#[derive(Deserialize)]
pub struct UnitUpdateRequest {
    pub short_name: HashMap<String, String>,
    pub long_name: HashMap<String, String>,
}

#[derive(Deserialize)]
pub struct UnitCreateRequest {
    pub short_name: HashMap<String, String>,
    pub long_name: HashMap<String, String>,
}
