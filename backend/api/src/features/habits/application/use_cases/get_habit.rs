// Get habit use case

use uuid::Uuid;

use crate::features::habits::domain::entities::habit::Habit;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;

pub struct GetHabitUseCase {
    habit_repo: HabitRepositoryImpl,
}

impl GetHabitUseCase {
    pub fn new(habit_repo: HabitRepositoryImpl) -> Self {
        Self { habit_repo }
    }

    pub async fn execute(
        &self,
        habit_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Option<Habit>, String> {
        self.habit_repo
            .get_by_id_with_executor(habit_id, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to get habit: {}", e))
    }
}
