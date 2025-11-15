// Create public message report use case

use crate::core::constants::errors::AppError;
use crate::features::public_discussions::domain::entities::public_message_report::PublicMessageReport;
use crate::features::public_discussions::infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl;
use crate::features::public_discussions::infrastructure::repositories::public_message_report_repository::PublicMessageReportRepositoryImpl;

pub struct CreatePublicMessageReportUseCase {
    report_repo: PublicMessageReportRepositoryImpl,
    message_repo: PublicMessageRepositoryImpl,
}

impl CreatePublicMessageReportUseCase {
    pub fn new(
        report_repo: PublicMessageReportRepositoryImpl,
        message_repo: PublicMessageRepositoryImpl,
    ) -> Self {
        Self {
            report_repo,
            message_repo,
        }
    }

    pub async fn execute(
        &self,
        report: &PublicMessageReport,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify message exists
        self.message_repo
            .get_by_id_with_executor(report.message_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::PublicMessageNotFound)?;

        // Validate reason
        if report.reason.is_empty() {
            return Err(AppError::PublicMessageReportReasonEmpty);
        }
        if report.reason.len() > crate::features::public_discussions::domain::entities::public_message_report::PUBLIC_MESSAGE_REPORT_CONTENT_MAX_LENGTH {
            return Err(AppError::PublicMessageReportReasonTooLong);
        }

        // Create report
        self.report_repo
            .create_with_executor(report, &mut **transaction)
            .await
            .map_err(|_| AppError::PublicMessageReportCreation)?;

        Ok(())
    }
}
