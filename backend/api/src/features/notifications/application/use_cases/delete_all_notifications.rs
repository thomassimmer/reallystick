// Delete all notifications use case

use crate::features::notifications::infrastructure::repositories::notification_repository::NotificationRepositoryImpl;
use uuid::Uuid;

pub struct DeleteAllNotificationsUseCase {
    notification_repo: NotificationRepositoryImpl,
}

impl DeleteAllNotificationsUseCase {
    pub fn new(notification_repo: NotificationRepositoryImpl) -> Self {
        Self { notification_repo }
    }

    pub async fn execute(
        &self,
        user_id: Uuid,
        transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    ) -> Result<(), String> {
        self.notification_repo
            .delete_all_by_user_id_with_executor(user_id, &mut **transaction)
            .await
            .map_err(|e| e.to_string())?;
        Ok(())
    }
}
