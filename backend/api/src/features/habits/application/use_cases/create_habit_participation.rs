// Create habit participation use case

use crate::core::constants::errors::AppError;
use crate::features::habits::domain::entities::habit_participation::HabitParticipation;
use crate::features::habits::infrastructure::repositories::habit_participation_repository::HabitParticipationRepositoryImpl;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;

pub struct CreateHabitParticipationUseCase {
    participation_repo: HabitParticipationRepositoryImpl,
    habit_repo: HabitRepositoryImpl,
}

impl CreateHabitParticipationUseCase {
    pub fn new(
        participation_repo: HabitParticipationRepositoryImpl,
        habit_repo: HabitRepositoryImpl,
    ) -> Self {
        Self {
            participation_repo,
            habit_repo,
        }
    }

    pub async fn execute(
        &self,
        participation: &HabitParticipation,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify habit exists
        self.habit_repo
            .get_by_id_with_executor(participation.habit_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::HabitNotFound)?;

        // Check if participation already exists
        if self
            .participation_repo
            .get_by_user_and_habit_id_with_executor(
                participation.user_id,
                participation.habit_id,
                &mut **transaction,
            )
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .is_some()
        {
            return Err(AppError::HabitParticipationCreation);
        }

        // Create participation
        self.participation_repo
            .create_with_executor(participation, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?;

        Ok(())
    }
}
