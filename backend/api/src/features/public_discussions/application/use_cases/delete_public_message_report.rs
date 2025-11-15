// Delete public message report use case

use crate::core::constants::errors::AppError;
use crate::features::public_discussions::infrastructure::repositories::public_message_report_repository::PublicMessageReportRepositoryImpl;
use uuid::Uuid;

pub struct DeletePublicMessageReportUseCase {
    report_repo: PublicMessageReportRepositoryImpl,
}

impl DeletePublicMessageReportUseCase {
    pub fn new(report_repo: PublicMessageReportRepositoryImpl) -> Self {
        Self { report_repo }
    }

    pub async fn execute(
        &self,
        report_id: Uuid,
        user_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify report exists and belongs to user
        let report = self
            .report_repo
            .get_by_id_with_executor(report_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::PublicMessageReportNotFound)?;

        if report.reporter != user_id {
            return Err(AppError::PublicMessageReportReporterIsNotRequestUser);
        }

        // Delete report
        self.report_repo
            .delete_with_executor(report_id, &mut **transaction)
            .await
            .map_err(|_| AppError::PublicMessageReportDeletion)?;

        Ok(())
    }
}
