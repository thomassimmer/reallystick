use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        notifications::{
            helpers::notification::get_user_notifications,
            structs::responses::NotificationsResponse,
        },
    },
};
use actix_web::{
    get,
    web::{self, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/")]
pub async fn get_notifications(claims: ReqData<Claims>, pool: web::Data<PgPool>) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let notifications = match get_user_notifications(&mut transaction, claims.user_id).await {
        Ok(r) => r,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(NotificationsResponse {
        code: "NOTIFICATIONS_FETCHED".to_string(),
        notifications: notifications
            .iter()
            .map(|n| n.to_notification_data())
            .collect(),
    })
}
