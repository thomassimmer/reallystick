// Update private discussion participation use case

use crate::core::constants::errors::AppError;
use crate::features::private_discussions::domain::entities::private_discussion_participation::PrivateDiscussionParticipation;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_participation_repository::PrivateDiscussionParticipationRepositoryImpl;
use uuid::Uuid;

pub struct UpdatePrivateDiscussionParticipationUseCase {
    participation_repo: PrivateDiscussionParticipationRepositoryImpl,
}

impl UpdatePrivateDiscussionParticipationUseCase {
    pub fn new(participation_repo: PrivateDiscussionParticipationRepositoryImpl) -> Self {
        Self { participation_repo }
    }

    pub async fn execute(
        &self,
        participation: &PrivateDiscussionParticipation,
        user_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Verify participation exists and belongs to user
        let _existing = self
            .participation_repo
            .get_by_user_and_discussion_with_executor(
                user_id,
                participation.discussion_id,
                &mut **transaction,
            )
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::PrivateDiscussionParticipationNotFound)?;

        // Update participation
        self.participation_repo
            .update_with_executor(participation, &mut **transaction)
            .await
            .map_err(|_| AppError::PrivateDiscussionParticipationUpdate)?;

        Ok(())
    }
}
