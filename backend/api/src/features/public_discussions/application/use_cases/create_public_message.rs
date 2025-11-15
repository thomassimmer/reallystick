// Create public message use case

use crate::core::constants::errors::AppError;
use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;
use crate::features::public_discussions::domain::entities::public_message::{
    PublicMessage, PUBLIC_MESSAGE_CONTENT_MAX_LENGTH,
};
use crate::features::public_discussions::infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl;
use sqlx::Postgres;

pub struct CreatePublicMessageUseCase {
    message_repo: PublicMessageRepositoryImpl,
    habit_repo: HabitRepositoryImpl,
    challenge_repo: ChallengeRepositoryImpl,
}

impl CreatePublicMessageUseCase {
    pub fn new(
        message_repo: PublicMessageRepositoryImpl,
        habit_repo: HabitRepositoryImpl,
        challenge_repo: ChallengeRepositoryImpl,
    ) -> Self {
        Self {
            message_repo,
            habit_repo,
            challenge_repo,
        }
    }

    pub async fn execute(
        &self,
        public_message: &PublicMessage,
        transaction: &mut sqlx::Transaction<'_, Postgres>,
    ) -> Result<(), AppError> {
        // Check if a habit or a challenge is given
        if public_message.habit_id.is_none() && public_message.challenge_id.is_none() {
            return Err(AppError::NoHabitNorChallengePassed);
        }

        // Check if a habit and a challenge were given
        if public_message.habit_id.is_some() && public_message.challenge_id.is_some() {
            return Err(AppError::BothHabitAndChallengePassed);
        }

        // Check if habit exists
        if let Some(habit_id) = public_message.habit_id {
            self.habit_repo
                .get_by_id_with_executor(habit_id, &mut **transaction)
                .await
                .map_err(|_| AppError::DatabaseQuery)?
                .ok_or(AppError::HabitNotFound)?;
        }

        // Check if challenge exists
        if let Some(challenge_id) = public_message.challenge_id {
            self.challenge_repo
                .get_by_id_with_executor(challenge_id, &mut **transaction)
                .await
                .map_err(|_| AppError::DatabaseQuery)?
                .ok_or(AppError::ChallengeNotFound)?;
        }

        // Check if replies_to exists
        if let Some(replies_to) = public_message.replies_to {
            let mut parent_message = self
                .message_repo
                .get_by_id_with_executor(replies_to, &mut **transaction)
                .await
                .map_err(|_| AppError::DatabaseQuery)?
                .ok_or(AppError::PublicMessageNotFound)?;

            // Increment reply count of parent message
            parent_message.reply_count += 1;
            self.message_repo
                .update_reply_count_with_executor(&parent_message, &mut **transaction)
                .await
                .map_err(|_| AppError::PublicMessageUpdate)?;
        }

        // Check content size
        if public_message.content.len() > PUBLIC_MESSAGE_CONTENT_MAX_LENGTH {
            return Err(AppError::PublicMessageContentTooLong);
        } else if public_message.content.is_empty() {
            return Err(AppError::PublicMessageContentEmpty);
        }

        // Create message
        self.message_repo
            .create_with_executor(public_message, &mut **transaction)
            .await
            .map_err(|_| AppError::PublicMessageCreation)?;

        Ok(())
    }
}
