// Update public message use case

use crate::core::constants::errors::AppError;
use crate::features::public_discussions::domain::entities::public_message::PublicMessage;
use crate::features::public_discussions::infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl;
use uuid::Uuid;

pub struct UpdatePublicMessageUseCase {
    message_repo: PublicMessageRepositoryImpl,
}

impl UpdatePublicMessageUseCase {
    pub fn new(message_repo: PublicMessageRepositoryImpl) -> Self {
        Self { message_repo }
    }

    pub async fn execute(
        &self,
        message: &PublicMessage,
        creator_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify message exists
        let existing_message = self
            .message_repo
            .get_by_id_with_executor(message.id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::PublicMessageNotFound)?;

        // Check if user is creator
        if existing_message.creator != creator_id {
            return Err(AppError::PublicMessageUpdateNotDoneByCreator);
        }

        // Validate content
        if message.content.is_empty() {
            return Err(AppError::PublicMessageContentEmpty);
        }
        if message.content.len() > crate::features::public_discussions::domain::entities::public_message::PUBLIC_MESSAGE_CONTENT_MAX_LENGTH {
            return Err(AppError::PublicMessageContentTooLong);
        }

        // Update message
        self.message_repo
            .update_with_executor(message, &mut **transaction)
            .await
            .map_err(|_| AppError::PublicMessageUpdate)?;

        Ok(())
    }
}
