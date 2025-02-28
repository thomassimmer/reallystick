use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::{collections::HashSet, sync::Arc};
use tokio::sync::RwLock;
use uuid::Uuid;

use crate::core::helpers::mock_now::now;

#[derive(Clone, Serialize, Deserialize, Debug)]
pub struct HabitStatistics {
    pub habit_id: Uuid,
    pub participants_count: i64,
    pub top_ages: HashSet<(String, i64)>,
    pub top_countries: HashSet<(String, i64)>,
    pub top_regions: HashSet<(String, i64)>,
    pub top_has_children: HashSet<(String, i64)>,
    pub top_lives_in_urban_area: HashSet<(String, i64)>,
    pub top_gender: HashSet<(String, i64)>,
    pub top_activities: HashSet<(String, i64)>,
    pub top_financial_situations: HashSet<(String, i64)>,
    pub top_relationship_statuses: HashSet<(String, i64)>,
    pub top_levels_of_education: HashSet<(String, i64)>,
}

pub struct HabitStatisticsCache {
    data: Arc<RwLock<Vec<HabitStatistics>>>,
    last_updated: Arc<RwLock<Option<DateTime<Utc>>>>,
}

impl Default for HabitStatisticsCache {
    fn default() -> Self {
        Self::new()
    }
}

impl HabitStatisticsCache {
    pub fn new() -> Self {
        Self {
            data: Arc::new(RwLock::new(Vec::new())),
            last_updated: Arc::new(RwLock::new(None)),
        }
    }

    pub async fn needs_update(&self) -> bool {
        let last_updated = self.last_updated.read().await;
        match *last_updated {
            Some(timestamp) => now() - timestamp > chrono::Duration::hours(1),
            None => true,
        }
    }

    pub async fn update(&self, new_data: Vec<HabitStatistics>) {
        *self.data.write().await = new_data;
        *self.last_updated.write().await = Some(now());
    }

    pub async fn get_data(&self) -> Vec<HabitStatistics> {
        self.data.read().await.clone()
    }
}
