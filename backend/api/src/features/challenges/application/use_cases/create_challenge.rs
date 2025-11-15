// Create challenge use case

use crate::features::challenges::domain::entities::challenge::Challenge;
use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;

pub struct CreateChallengeUseCase {
    challenge_repo: ChallengeRepositoryImpl,
}

impl CreateChallengeUseCase {
    pub fn new(challenge_repo: ChallengeRepositoryImpl) -> Self {
        Self { challenge_repo }
    }

    pub async fn execute(
        &self,
        challenge: &Challenge,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), String> {
        self.challenge_repo
            .create_with_executor(challenge, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to create challenge: {}", e))?;
        Ok(())
    }
}
