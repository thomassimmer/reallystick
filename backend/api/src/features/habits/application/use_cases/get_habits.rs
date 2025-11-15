// Get habits use case

use uuid::Uuid;

use crate::features::habits::domain::entities::habit::Habit;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;

pub struct GetHabitsUseCase {
    habit_repo: HabitRepositoryImpl,
}

impl GetHabitsUseCase {
    pub fn new(habit_repo: HabitRepositoryImpl) -> Self {
        Self { habit_repo }
    }

    pub async fn execute(
        &self,
        user_id: Option<Uuid>,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Vec<Habit>, String> {
        match user_id {
            Some(user_id) => {
                // Get reviewed and personal habits for user
                self.habit_repo
                    .get_reviewed_and_personal_with_executor(user_id, &mut **transaction)
                    .await
                    .map_err(|e| format!("Failed to get habits: {}", e))
            }
            None => {
                // Get all habits
                self.habit_repo
                    .get_all_with_executor(&mut **transaction)
                    .await
                    .map_err(|e| format!("Failed to get habits: {}", e))
            }
        }
    }
}
