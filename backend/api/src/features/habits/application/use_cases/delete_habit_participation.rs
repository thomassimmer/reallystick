// Delete habit participation use case

use crate::core::constants::errors::AppError;
use crate::features::habits::infrastructure::repositories::habit_participation_repository::HabitParticipationRepositoryImpl;
use uuid::Uuid;

pub struct DeleteHabitParticipationUseCase {
    participation_repo: HabitParticipationRepositoryImpl,
}

impl DeleteHabitParticipationUseCase {
    pub fn new(participation_repo: HabitParticipationRepositoryImpl) -> Self {
        Self { participation_repo }
    }

    pub async fn execute(
        &self,
        participation_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        self.participation_repo
            .delete_with_executor(participation_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?;

        Ok(())
    }
}
