// Update habit participation use case

use crate::core::constants::errors::AppError;
use crate::features::habits::domain::entities::habit_participation::HabitParticipation;
use crate::features::habits::infrastructure::repositories::habit_participation_repository::HabitParticipationRepositoryImpl;

pub struct UpdateHabitParticipationUseCase {
    participation_repo: HabitParticipationRepositoryImpl,
}

impl UpdateHabitParticipationUseCase {
    pub fn new(participation_repo: HabitParticipationRepositoryImpl) -> Self {
        Self { participation_repo }
    }

    pub async fn execute(
        &self,
        participation: &HabitParticipation,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify participation exists
        self.participation_repo
            .get_by_id_with_executor(participation.id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::HabitParticipationNotFound)?;

        // Update participation
        self.participation_repo
            .update_with_executor(participation, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?;

        Ok(())
    }
}
