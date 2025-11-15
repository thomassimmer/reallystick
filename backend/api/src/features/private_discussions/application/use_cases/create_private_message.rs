// Create private message use case

use crate::core::constants::errors::AppError;
use crate::features::private_discussions::domain::entities::private_message::PrivateMessage;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_repository::PrivateDiscussionRepositoryImpl;
use crate::features::private_discussions::infrastructure::repositories::private_message_repository::PrivateMessageRepositoryImpl;

pub struct CreatePrivateMessageUseCase {
    message_repo: PrivateMessageRepositoryImpl,
    discussion_repo: PrivateDiscussionRepositoryImpl,
}

impl CreatePrivateMessageUseCase {
    pub fn new(
        message_repo: PrivateMessageRepositoryImpl,
        discussion_repo: PrivateDiscussionRepositoryImpl,
    ) -> Self {
        Self {
            message_repo,
            discussion_repo,
        }
    }

    pub async fn execute(
        &self,
        message: &PrivateMessage,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify discussion exists
        self.discussion_repo
            .get_by_id_with_executor(message.discussion_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::PrivateDiscussionNotFound)?;

        // Validate content
        if message.content.is_empty() {
            return Err(AppError::PrivateMessageContentEmpty);
        }
        if message.content.len() > crate::features::private_discussions::domain::entities::private_message::PRIVATE_MESSAGE_CONTENT_MAX_LENGTH {
            return Err(AppError::PrivateMessageContentTooLong);
        }

        // Create message
        self.message_repo
            .create_with_executor(message, &mut **transaction)
            .await
            .map_err(|_| AppError::PrivateMessageCreation)?;

        Ok(())
    }
}
