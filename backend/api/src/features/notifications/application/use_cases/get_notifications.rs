// Get notifications use case - retrieves all notifications for a user

use crate::features::notifications::domain::entities::Notification;
use crate::features::notifications::infrastructure::repositories::notification_repository::NotificationRepositoryImpl;
use uuid::Uuid;

pub struct GetNotificationsUseCase {
    notification_repo: NotificationRepositoryImpl,
}

impl GetNotificationsUseCase {
    pub fn new(notification_repo: NotificationRepositoryImpl) -> Self {
        Self { notification_repo }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<Vec<Notification>, String> {
        self.notification_repo
            .get_by_user_id_with_executor(user_id, &mut **transaction)
            .await
            .map_err(|e| e.to_string())
    }
}
