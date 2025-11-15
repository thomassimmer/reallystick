// Get habit categories use case

use crate::features::habits::domain::entities::habit_category::HabitCategory;
use crate::features::habits::infrastructure::repositories::habit_category_repository::HabitCategoryRepositoryImpl;

pub struct GetHabitCategoriesUseCase {
    category_repo: HabitCategoryRepositoryImpl,
}

impl GetHabitCategoriesUseCase {
    pub fn new(category_repo: HabitCategoryRepositoryImpl) -> Self {
        Self { category_repo }
    }

    pub async fn execute(
        &self,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Vec<HabitCategory>, String> {
        self.category_repo
            .get_all_with_executor(&mut **transaction)
            .await
            .map_err(|e| e.to_string())
    }
}
