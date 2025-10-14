use crate::{
    core::constants::errors::AppError,
    features::notifications::{
        helpers,
        structs::{requests::DeleteNotificationParams, responses::NotificationResponse},
    },
};
use actix_web::{
    delete,
    web::{Data, Path},
    HttpResponse, Responder,
};
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

    if let Err(e) = helpers::notification::delete_notification(&mut *transaction, params.id).await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(NotificationResponse {
        code: "NOTIFICATION_DELETED".to_string(),
    })
}
