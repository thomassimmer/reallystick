// Update habit category use case

use crate::core::constants::errors::AppError;
use crate::features::habits::domain::entities::habit_category::HabitCategory;
use crate::features::habits::infrastructure::repositories::habit_category_repository::HabitCategoryRepositoryImpl;

pub struct UpdateHabitCategoryUseCase {
    category_repo: HabitCategoryRepositoryImpl,
}

impl UpdateHabitCategoryUseCase {
    pub fn new(category_repo: HabitCategoryRepositoryImpl) -> Self {
        Self { category_repo }
    }

    pub async fn execute(
        &self,
        category: &HabitCategory,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify category exists
        match self
            .category_repo
            .get_by_id_with_executor(category.id, &mut **transaction)
            .await
        {
            Ok(Some(_)) => {}
            Ok(None) => return Err(AppError::HabitCategoryNotFound),
            Err(_) => return Err(AppError::DatabaseQuery),
        }

        // Update category
        self.category_repo
            .update_with_executor(category, &mut **transaction)
            .await
            .map_err(|_| AppError::HabitUpdate)?;
        Ok(())
    }
}
