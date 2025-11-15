// Delete habit daily tracking use case

use crate::core::constants::errors::AppError;
use crate::features::habits::infrastructure::repositories::habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl;
use uuid::Uuid;

pub struct DeleteHabitDailyTrackingUseCase {
    tracking_repo: HabitDailyTrackingRepositoryImpl,
}

impl DeleteHabitDailyTrackingUseCase {
    pub fn new(tracking_repo: HabitDailyTrackingRepositoryImpl) -> Self {
        Self { tracking_repo }
    }

    pub async fn execute(
        &self,
        tracking_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        self.tracking_repo
            .delete_with_executor(tracking_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?;

        Ok(())
    }
}
