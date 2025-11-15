// Delete challenge use case

use uuid::Uuid;

use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;

pub struct DeleteChallengeUseCase {
    challenge_repo: ChallengeRepositoryImpl,
}

impl DeleteChallengeUseCase {
    pub fn new(challenge_repo: ChallengeRepositoryImpl) -> Self {
        Self { challenge_repo }
    }

    pub async fn execute(
        &self,
        challenge_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), String> {
        self.challenge_repo
            .delete_with_executor(challenge_id, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to delete challenge: {}", e))?;
        Ok(())
    }
}
