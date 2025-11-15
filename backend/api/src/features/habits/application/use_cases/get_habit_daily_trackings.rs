// Get habit daily trackings use case

use crate::features::habits::domain::entities::habit_daily_tracking::HabitDailyTracking;
use crate::features::habits::infrastructure::repositories::habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl;
use uuid::Uuid;

pub struct GetHabitDailyTrackingsUseCase {
    tracking_repo: HabitDailyTrackingRepositoryImpl,
}

impl GetHabitDailyTrackingsUseCase {
    pub fn new(tracking_repo: HabitDailyTrackingRepositoryImpl) -> Self {
        Self { tracking_repo }
    }

    pub async fn execute(
        &self,
        habit_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Vec<HabitDailyTracking>, String> {
        self.tracking_repo
            .get_by_habit_id_with_executor(habit_id, &mut **transaction)
            .await
            .map_err(|e| e.to_string())
    }
}
