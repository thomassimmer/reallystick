// Update unit use case

use crate::core::constants::errors::AppError;
use crate::features::habits::domain::entities::unit::Unit;
use crate::features::habits::infrastructure::repositories::unit_repository::UnitRepositoryImpl;

pub struct UpdateUnitUseCase {
    unit_repo: UnitRepositoryImpl,
}

impl UpdateUnitUseCase {
    pub fn new(unit_repo: UnitRepositoryImpl) -> Self {
        Self { unit_repo }
    }

    pub async fn execute(
        &self,
        unit: &Unit,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify unit exists
        match self
            .unit_repo
            .get_by_id_with_executor(unit.id, &mut **transaction)
            .await
        {
            Ok(Some(_)) => {}
            Ok(None) => return Err(AppError::UnitNotFound),
            Err(_) => return Err(AppError::DatabaseQuery),
        }

        // Update unit
        self.unit_repo
            .update_with_executor(unit, &mut **transaction)
            .await
            .map_err(|_| AppError::UnitUpdate)?;
        Ok(())
    }
}
