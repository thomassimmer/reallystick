// Create private discussion use case

use crate::core::constants::errors::AppError;
use crate::features::private_discussions::domain::entities::private_discussion::PrivateDiscussion;
use crate::features::private_discussions::domain::entities::private_discussion_participation::PrivateDiscussionParticipation;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_participation_repository::PrivateDiscussionParticipationRepositoryImpl;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_repository::PrivateDiscussionRepositoryImpl;

pub struct CreatePrivateDiscussionUseCase {
    discussion_repo: PrivateDiscussionRepositoryImpl,
    participation_repo: PrivateDiscussionParticipationRepositoryImpl,
}

impl CreatePrivateDiscussionUseCase {
    pub fn new(
        discussion_repo: PrivateDiscussionRepositoryImpl,
        participation_repo: PrivateDiscussionParticipationRepositoryImpl,
    ) -> Self {
        Self {
            discussion_repo,
            participation_repo,
        }
    }

    pub async fn execute(
        &self,
        discussion: &PrivateDiscussion,
        participation1: &PrivateDiscussionParticipation,
        participation2: &PrivateDiscussionParticipation,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), AppError> {
        // Create discussion
        self.discussion_repo
            .create_with_executor(discussion, &mut **transaction)
            .await
            .map_err(|_| AppError::PrivateDiscussionCreation)?;

        // Create participations
        self.participation_repo
            .create_with_executor(participation1, &mut **transaction)
            .await
            .map_err(|_| AppError::PrivateDiscussionParticipationCreation)?;

        self.participation_repo
            .create_with_executor(participation2, &mut **transaction)
            .await
            .map_err(|_| AppError::PrivateDiscussionParticipationCreation)?;

        Ok(())
    }
}
