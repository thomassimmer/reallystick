// Delete private message use case

use crate::core::constants::errors::AppError;
use crate::features::private_discussions::infrastructure::repositories::private_message_repository::PrivateMessageRepositoryImpl;
use uuid::Uuid;

pub struct DeletePrivateMessageUseCase {
    message_repo: PrivateMessageRepositoryImpl,
}

impl DeletePrivateMessageUseCase {
    pub fn new(message_repo: PrivateMessageRepositoryImpl) -> Self {
        Self { message_repo }
    }

    pub async fn execute(
        &self,
        message_id: Uuid,
        creator_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify message exists and user is creator
        let message = self
            .message_repo
            .get_by_id_with_executor(message_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::PrivateMessageNotFound)?;

        if message.creator != creator_id {
            return Err(AppError::PrivateMessageDeletionNotDoneByCreator);
        }

        // Delete message (soft delete)
        self.message_repo
            .delete_with_executor(message_id, &mut **transaction)
            .await
            .map_err(|_| AppError::PrivateMessageDeletion)?;

        Ok(())
    }
}
