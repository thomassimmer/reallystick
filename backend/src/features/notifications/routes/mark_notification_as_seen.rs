use actix_web::{
    put,
    web::{self},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

use crate::{
    core::constants::errors::AppError,
    features::notifications::{
        helpers,
        structs::{requests::MarkNotificationAsSeenParams, responses::NotificationResponse},
    },
};

#[put("/mark-as-seen/{id}")]
pub async fn mark_notification_as_seen(
    params: web::Path<MarkNotificationAsSeenParams>,
    pool: web::Data<PgPool>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    if let Err(e) =
        helpers::notification::mark_notification_as_seen(&mut *transaction, params.id).await
    {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(NotificationResponse {
        code: "NOTIFICATION_MARKED_AS_SEEN".to_string(),
    })
}
