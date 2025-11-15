// Create habit daily tracking use case

use crate::core::constants::errors::AppError;
use crate::features::habits::domain::entities::habit_daily_tracking::HabitDailyTracking;
use crate::features::habits::infrastructure::repositories::habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;

pub struct CreateHabitDailyTrackingUseCase {
    tracking_repo: HabitDailyTrackingRepositoryImpl,
    habit_repo: HabitRepositoryImpl,
}

impl CreateHabitDailyTrackingUseCase {
    pub fn new(
        tracking_repo: HabitDailyTrackingRepositoryImpl,
        habit_repo: HabitRepositoryImpl,
    ) -> Self {
        Self {
            tracking_repo,
            habit_repo,
        }
    }

    pub async fn execute(
        &self,
        tracking: &HabitDailyTracking,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify habit exists
        self.habit_repo
            .get_by_id_with_executor(tracking.habit_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::HabitNotFound)?;

        // Create tracking
        self.tracking_repo
            .create_with_executor(tracking, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?;

        Ok(())
    }
}
