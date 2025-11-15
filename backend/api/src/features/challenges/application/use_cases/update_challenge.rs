// Update challenge use case

use crate::features::challenges::domain::entities::challenge::Challenge;
use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;

pub struct UpdateChallengeUseCase {
    challenge_repo: ChallengeRepositoryImpl,
}

impl UpdateChallengeUseCase {
    pub fn new(challenge_repo: ChallengeRepositoryImpl) -> Self {
        Self { challenge_repo }
    }

    pub async fn execute(
        &self,
        challenge: &Challenge,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), String> {
        self.challenge_repo
            .update_with_executor(challenge, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to update challenge: {}", e))?;
        Ok(())
    }
}
