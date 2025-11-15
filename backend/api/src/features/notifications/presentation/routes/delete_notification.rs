// Delete notification route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::notifications::application::dto::requests::DeleteNotificationParams;
use crate::features::notifications::application::dto::responses::NotificationResponse;
use crate::features::notifications::application::use_cases::delete_notification::DeleteNotificationUseCase;
use crate::features::notifications::infrastructure::repositories::notification_repository::NotificationRepositoryImpl;
use actix_web::web::{Data, Path};
use actix_web::{delete, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[delete("/{id}")]
pub async fn delete_notification(
    pool: Data<PgPool>,
    params: Path<DeleteNotificationParams>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repository and use case
    let pool_clone = pool.get_ref().clone();
    let notification_repo = NotificationRepositoryImpl::new(pool_clone);
    let delete_notification_use_case = DeleteNotificationUseCase::new(notification_repo);

    // Execute use case
    let result = delete_notification_use_case
        .execute(params.id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(NotificationResponse {
            code: "NOTIFICATION_DELETED".to_string(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
