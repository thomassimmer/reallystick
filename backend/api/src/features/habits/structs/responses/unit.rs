use serde::{Deserialize, Serialize};

use crate::features::habits::structs::models::unit::UnitData;

#[derive(Serialize, Deserialize)]
pub struct UnitResponse {
    pub code: String,
    pub unit: Option<UnitData>,
}

#[derive(Serialize, Deserialize)]
pub struct UnitsResponse {
    pub code: String,
    pub units: Vec<UnitData>,
}
