// Create unit use case

use crate::core::constants::errors::AppError;
use crate::features::habits::domain::entities::unit::Unit;
use crate::features::habits::infrastructure::repositories::unit_repository::UnitRepositoryImpl;

pub struct CreateUnitUseCase {
    unit_repo: UnitRepositoryImpl,
}

impl CreateUnitUseCase {
    pub fn new(unit_repo: UnitRepositoryImpl) -> Self {
        Self { unit_repo }
    }

    pub async fn execute(
        &self,
        unit: &Unit,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        self.unit_repo
            .create_with_executor(unit, &mut **transaction)
            .await
            .map_err(|_| AppError::UnitCreation)?;
        Ok(())
    }
}
