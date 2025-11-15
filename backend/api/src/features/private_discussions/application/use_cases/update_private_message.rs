// Update private message use case

use crate::core::constants::errors::AppError;
use crate::features::private_discussions::domain::entities::private_message::PrivateMessage;
use crate::features::private_discussions::infrastructure::repositories::private_message_repository::PrivateMessageRepositoryImpl;
use uuid::Uuid;

pub struct UpdatePrivateMessageUseCase {
    message_repo: PrivateMessageRepositoryImpl,
}

impl UpdatePrivateMessageUseCase {
    pub fn new(message_repo: PrivateMessageRepositoryImpl) -> Self {
        Self { message_repo }
    }

    pub async fn execute(
        &self,
        message: &PrivateMessage,
        creator_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify message exists
        let existing_message = self
            .message_repo
            .get_by_id_with_executor(message.id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::PrivateMessageNotFound)?;

        // Check if user is creator
        if existing_message.creator != creator_id {
            return Err(AppError::PrivateMessageUpdateNotDoneByCreator);
        }

        // Validate content
        if message.content.is_empty() {
            return Err(AppError::PrivateMessageContentEmpty);
        }
        if message.content.len() > crate::features::private_discussions::domain::entities::private_message::PRIVATE_MESSAGE_CONTENT_MAX_LENGTH {
            return Err(AppError::PrivateMessageContentTooLong);
        }

        // Update message
        self.message_repo
            .update_with_executor(message, &mut **transaction)
            .await
            .map_err(|_| AppError::PrivateMessageUpdate)?;

        Ok(())
    }
}
