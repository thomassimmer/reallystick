// Get notifications route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::notifications::application::dto::responses::NotificationsResponse;
use crate::features::notifications::application::use_cases::get_notifications::GetNotificationsUseCase;
use crate::features::notifications::infrastructure::repositories::notification_repository::NotificationRepositoryImpl;
use actix_web::web::{Data, ReqData};
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_notifications(claims: ReqData<Claims>, pool: Data<PgPool>) -> impl Responder {
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
    let get_notifications_use_case = GetNotificationsUseCase::new(notification_repo);

    // Execute use case
    let result = get_notifications_use_case
        .execute(claims.user_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(notifications) => HttpResponse::Ok().json(NotificationsResponse {
            code: "NOTIFICATIONS_FETCHED".to_string(),
            notifications: notifications
                .iter()
                .map(|n| n.to_notification_data())
                .collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
