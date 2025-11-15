// Get habit participations use case

use crate::features::habits::domain::entities::habit_participation::HabitParticipation;
use crate::features::habits::infrastructure::repositories::habit_participation_repository::HabitParticipationRepositoryImpl;
use uuid::Uuid;

pub struct GetHabitParticipationsUseCase {
    participation_repo: HabitParticipationRepositoryImpl,
}

impl GetHabitParticipationsUseCase {
    pub fn new(participation_repo: HabitParticipationRepositoryImpl) -> Self {
        Self { participation_repo }
    }

    pub async fn execute(
        &self,
        habit_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Vec<HabitParticipation>, String> {
        self.participation_repo
            .get_by_habit_id_with_executor(habit_id, &mut **transaction)
            .await
            .map_err(|e| e.to_string())
    }
}
