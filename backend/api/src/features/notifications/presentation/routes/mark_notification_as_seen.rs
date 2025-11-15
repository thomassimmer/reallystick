// Mark notification as seen route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::notifications::application::dto::requests::MarkNotificationAsSeenParams;
use crate::features::notifications::application::dto::responses::NotificationResponse;
use crate::features::notifications::application::use_cases::mark_notification_as_seen::MarkNotificationAsSeenUseCase;
use crate::features::notifications::infrastructure::repositories::notification_repository::NotificationRepositoryImpl;
use actix_web::web::{Data, Path};
use actix_web::{put, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[put("/mark-as-seen/{id}")]
pub async fn mark_notification_as_seen(
    params: Path<MarkNotificationAsSeenParams>,
    pool: Data<PgPool>,
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
    let mark_as_seen_use_case = MarkNotificationAsSeenUseCase::new(notification_repo);

    // Execute use case
    let result = mark_as_seen_use_case
        .execute(params.id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(NotificationResponse {
            code: "NOTIFICATION_MARKED_AS_SEEN".to_string(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
