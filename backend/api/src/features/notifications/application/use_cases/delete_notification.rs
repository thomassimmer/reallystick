// Delete notification use case

use crate::features::notifications::infrastructure::repositories::notification_repository::NotificationRepositoryImpl;
use uuid::Uuid;

pub struct DeleteNotificationUseCase {
    notification_repo: NotificationRepositoryImpl,
}

impl DeleteNotificationUseCase {
    pub fn new(notification_repo: NotificationRepositoryImpl) -> Self {
        Self { notification_repo }
    }

    pub async fn execute(
        &self,
        notification_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), String> {
        self.notification_repo
            .delete_with_executor(notification_id, &mut **transaction)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }
}
