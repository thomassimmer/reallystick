// Get habit statistics use case

use crate::features::habits::domain::entities::habit_statistics::HabitStatistics;
use crate::features::habits::infrastructure::services::habit_statistics_service::HabitStatisticsService;

pub struct GetHabitStatisticsUseCase {
    statistics_service: HabitStatisticsService,
}

impl GetHabitStatisticsUseCase {
    pub fn new(statistics_service: HabitStatisticsService) -> Self {
        Self { statistics_service }
    }

    pub async fn execute(&self) -> Result<Vec<HabitStatistics>, String> {
        self.statistics_service
            .fetch_habit_statistics()
            .await
            .map_err(|e| e.to_string())
    }
}
