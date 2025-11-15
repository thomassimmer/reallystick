// Get challenge use case

use uuid::Uuid;

use crate::features::challenges::domain::entities::challenge::Challenge;
use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;

pub struct GetChallengeUseCase {
    challenge_repo: ChallengeRepositoryImpl,
}

impl GetChallengeUseCase {
    pub fn new(challenge_repo: ChallengeRepositoryImpl) -> Self {
        Self { challenge_repo }
    }

    pub async fn execute(
        &self,
        challenge_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Option<Challenge>, String> {
        self.challenge_repo
            .get_by_id_with_executor(challenge_id, &mut **transaction)
            .await
            .map_err(|e| format!("Failed to get challenge: {}", e))
    }
}
