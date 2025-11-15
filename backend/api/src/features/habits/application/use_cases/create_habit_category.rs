// Create habit category use case

use crate::core::constants::errors::AppError;
use crate::features::habits::domain::entities::habit_category::HabitCategory;
use crate::features::habits::infrastructure::repositories::habit_category_repository::HabitCategoryRepositoryImpl;

pub struct CreateHabitCategoryUseCase {
    category_repo: HabitCategoryRepositoryImpl,
}

impl CreateHabitCategoryUseCase {
    pub fn new(category_repo: HabitCategoryRepositoryImpl) -> Self {
        Self { category_repo }
    }

    pub async fn execute(
        &self,
        category: &HabitCategory,
        language_code: String,
        category_name: String,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Option<HabitCategory>, AppError> {
        // Check if category already exists
        match self
            .category_repo
            .get_by_name_with_executor(language_code, category_name, &mut **transaction)
            .await
        {
            Ok(Some(existing)) => return Ok(Some(existing)),
            Ok(None) => {}
            Err(_) => return Err(AppError::DatabaseQuery),
        }

        // Create category
        self.category_repo
            .create_with_executor(category, &mut **transaction)
            .await
            .map_err(|_| AppError::HabitCategoryCreation)?;

        Ok(None)
    }
}
