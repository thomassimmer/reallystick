// Delete public message use case

use crate::core::constants::errors::AppError;
use crate::features::public_discussions::infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl;
use uuid::Uuid;

pub struct DeletePublicMessageUseCase {
    message_repo: PublicMessageRepositoryImpl,
}

impl DeletePublicMessageUseCase {
    pub fn new(message_repo: PublicMessageRepositoryImpl) -> Self {
        Self { message_repo }
    }

    pub async fn execute(
        &self,
        message_id: Uuid,
        user_id: Uuid,
        is_admin: bool,
        deleted_by_admin: bool,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Option<Uuid>, AppError> {
        // Verify message exists
        let mut message = self
            .message_repo
            .get_by_id_with_executor(message_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::PublicMessageNotFound)?;

        // Check authorization
        if !deleted_by_admin && message.creator != user_id {
            return Err(AppError::PublicMessageDeletionNotDoneByCreator);
        }
        if deleted_by_admin && !is_admin {
            return Err(AppError::PublicMessageDeletionNotDoneByAdmin);
        }

        // Update deletion flags
        message.deleted_by_admin = deleted_by_admin;
        message.deleted_by_creator = !deleted_by_admin;

        // Delete message (soft delete)
        self.message_repo
            .delete_with_executor(&message, &mut **transaction)
            .await
            .map_err(|_| AppError::PublicMessageDeletion)?;

        // Return parent message ID if this is a reply (for updating reply count)
        Ok(message.replies_to)
    }
}
