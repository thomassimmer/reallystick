// Update habit use case

use crate::features::habits::domain::entities::habit::Habit;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;

pub struct UpdateHabitUseCase {
    habit_repo: HabitRepositoryImpl,
}

impl UpdateHabitUseCase {
    pub fn new(habit_repo: HabitRepositoryImpl) -> Self {
        Self { habit_repo }
    }

    pub async fn execute(
        &self,
        habit: &Habit,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), String> {
        self.habit_repo
            .update_with_executor(habit, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to update habit: {}", e))?;
        Ok(())
    }
}
