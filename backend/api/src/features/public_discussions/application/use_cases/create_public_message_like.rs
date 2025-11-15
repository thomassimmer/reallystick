// Create public message like use case

use crate::core::constants::errors::AppError;
use crate::features::public_discussions::domain::entities::public_message_like::PublicMessageLike;
use crate::features::public_discussions::infrastructure::repositories::public_message_like_repository::PublicMessageLikeRepositoryImpl;
use crate::features::public_discussions::infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl;
use uuid::Uuid;

pub struct CreatePublicMessageLikeUseCase {
    like_repo: PublicMessageLikeRepositoryImpl,
    message_repo: PublicMessageRepositoryImpl,
}

impl CreatePublicMessageLikeUseCase {
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
        like: &PublicMessageLike,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Uuid, AppError> {
        // Verify message exists
        let mut message = self
            .message_repo
            .get_by_id_with_executor(like.message_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::PublicMessageNotFound)?;

        // Create like (ON CONFLICT DO NOTHING handles duplicates)
        self.like_repo
            .create_with_executor(like, &mut **transaction)
            .await
            .map_err(|_| AppError::PublicMessageLikeCreation)?;

        // Update like count
        message.like_count += 1;
        self.message_repo
            .update_like_count_with_executor(&message, &mut **transaction)
            .await
            .map_err(|_| AppError::PublicMessageUpdate)?;

        // Return creator ID for notification
        Ok(message.creator)
    }
}
