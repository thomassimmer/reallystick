// Delete habit use case

use uuid::Uuid;

use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;

pub struct DeleteHabitUseCase {
    habit_repo: HabitRepositoryImpl,
}

impl DeleteHabitUseCase {
    pub fn new(habit_repo: HabitRepositoryImpl) -> Self {
        Self { habit_repo }
    }

    pub async fn execute(
        &self,
        habit_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), String> {
        self.habit_repo
            .delete_with_executor(habit_id, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to delete habit: {}", e))?;
        Ok(())
    }
}
