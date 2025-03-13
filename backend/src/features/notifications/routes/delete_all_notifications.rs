use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        notifications::{helpers, structs::responses::NotificationResponse},
    },
};
use actix_web::{
    delete,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[delete("/")]
pub async fn delete_all_notifications(
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
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
        helpers::notification::delete_user_notifications(&mut *transaction, request_claims.user_id)
            .await
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
        code: "NOTIFICATIONS_DELETED".to_string(),
    })
}
