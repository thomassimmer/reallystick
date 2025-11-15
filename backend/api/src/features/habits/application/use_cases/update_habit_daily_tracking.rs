// Update habit daily tracking use case

use crate::core::constants::errors::AppError;
use crate::features::habits::domain::entities::habit_daily_tracking::HabitDailyTracking;
use crate::features::habits::infrastructure::repositories::habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl;

pub struct UpdateHabitDailyTrackingUseCase {
    tracking_repo: HabitDailyTrackingRepositoryImpl,
}

impl UpdateHabitDailyTrackingUseCase {
    pub fn new(tracking_repo: HabitDailyTrackingRepositoryImpl) -> Self {
        Self { tracking_repo }
    }

    pub async fn execute(
        &self,
        tracking: &HabitDailyTracking,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify tracking exists
        self.tracking_repo
            .get_by_id_with_executor(tracking.id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::HabitDailyTrackingNotFound)?;

        // Update tracking
        self.tracking_repo
            .update_with_executor(tracking, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?;

        Ok(())
    }
}
