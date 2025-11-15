// Get challenge statistics use case

use crate::features::challenges::domain::entities::challenge_statistics::ChallengeStatistics;
use crate::features::challenges::infrastructure::services::challenge_statistics_service::ChallengeStatisticsService;

pub struct GetChallengeStatisticsUseCase {
    statistics_service: ChallengeStatisticsService,
}

impl GetChallengeStatisticsUseCase {
    pub fn new(statistics_service: ChallengeStatisticsService) -> Self {
        Self { statistics_service }
    }

    pub async fn execute(&self) -> Result<Vec<ChallengeStatistics>, String> {
        self.statistics_service
            .fetch_challenge_statistics()
            .await
            .map_err(|e| e.to_string())
    }
}
