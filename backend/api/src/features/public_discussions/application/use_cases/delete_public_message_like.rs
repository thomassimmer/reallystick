// Delete public message like use case

use crate::core::constants::errors::AppError;
use crate::features::public_discussions::infrastructure::repositories::public_message_like_repository::PublicMessageLikeRepositoryImpl;
use crate::features::public_discussions::infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl;
use uuid::Uuid;

pub struct DeletePublicMessageLikeUseCase {
    like_repo: PublicMessageLikeRepositoryImpl,
    message_repo: PublicMessageRepositoryImpl,
}

impl DeletePublicMessageLikeUseCase {
    pub fn new(
        like_repo: PublicMessageLikeRepositoryImpl,
        message_repo: PublicMessageRepositoryImpl,
    ) -> Self {
        Self {
            like_repo,
            message_repo,
        }
    }

    pub async fn execute(
        &self,
        message_id: Uuid,
        user_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify message exists
        let mut message = self
            .message_repo
            .get_by_id_with_executor(message_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::PublicMessageNotFound)?;

        // Verify like exists
        let like = self
            .like_repo
            .get_by_message_and_user_with_executor(message_id, user_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::PublicMessageLikeNotFound)?;

        // Delete like
        self.like_repo
            .delete_with_executor(like.id, &mut **transaction)
            .await
            .map_err(|_| AppError::PublicMessageLikeDeletion)?;

        // Update like count
        message.like_count -= 1;
        self.message_repo
            .update_like_count_with_executor(&message, &mut **transaction)
            .await
            .map_err(|_| AppError::PublicMessageUpdate)?;

        Ok(())
    }
}
