// Get units use case

use crate::features::habits::domain::entities::unit::Unit;
use crate::features::habits::infrastructure::repositories::unit_repository::UnitRepositoryImpl;

pub struct GetUnitsUseCase {
    unit_repo: UnitRepositoryImpl,
}

impl GetUnitsUseCase {
    pub fn new(unit_repo: UnitRepositoryImpl) -> Self {
        Self { unit_repo }
    }

    pub async fn execute(
        &self,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Vec<Unit>, String> {
        self.unit_repo
            .get_all_with_executor(&mut **transaction)
            .await
            .map_err(|e| e.to_string())
    }
}
