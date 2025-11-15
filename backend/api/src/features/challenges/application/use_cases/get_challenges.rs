// Get challenges use case

use uuid::Uuid;

use crate::features::challenges::domain::entities::challenge::Challenge;
use crate::features::challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl;

pub struct GetChallengesUseCase {
    challenge_repo: ChallengeRepositoryImpl,
}

impl GetChallengesUseCase {
    pub fn new(challenge_repo: ChallengeRepositoryImpl) -> Self {
        Self { challenge_repo }
    }

    pub async fn execute(
        &self,
        _user_id: Option<Uuid>,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Vec<Challenge>, String> {
        // match user_id {
        //     Some(user_id) => {
        //         // Get created and joined challenges for user
        //         self.challenge_repo
        //             .get_created_and_joined_with_executor(user_id, &mut **transaction)
        //             .await
        //             .map_err(|e| format!("Failed to get challenges: {}", e))
        //     }
        //     None => {
        // Get all challenges
        self.challenge_repo
            .get_all_with_executor(&mut **transaction)
            .await
            .map_err(|e| format!("Failed to get challenges: {}", e))
        // }
        // }
    }
}
