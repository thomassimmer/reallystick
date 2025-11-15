// Delete habit category use case

use crate::core::constants::errors::AppError;
use crate::features::habits::infrastructure::repositories::habit_category_repository::HabitCategoryRepositoryImpl;
use uuid::Uuid;

pub struct DeleteHabitCategoryUseCase {
    category_repo: HabitCategoryRepositoryImpl,
}

impl DeleteHabitCategoryUseCase {
    pub fn new(category_repo: HabitCategoryRepositoryImpl) -> Self {
        Self { category_repo }
    }

    pub async fn execute(
        &self,
        category_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        self.category_repo
            .delete_with_executor(category_id, &mut **transaction)
            .await
            .map_err(|_| AppError::HabitCategoryDelete)?;
        Ok(())
    }
}
