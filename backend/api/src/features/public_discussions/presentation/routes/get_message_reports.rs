use crate::{
    core::constants::errors::AppError,
    features::{
        auth::domain::entities::Claims,
        public_discussions::{
            application::dto::responses::public_message_report::PublicMessageReportsResponse,
            infrastructure::repositories::{
                public_message_report_repository::PublicMessageReportRepositoryImpl,
                public_message_repository::PublicMessageRepositoryImpl,
            },
        },
    },
};
use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_message_reports(
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    // Check if user is admin
    if !request_claims.is_admin {
        return HttpResponse::Forbidden().json(AppError::NotAdmin.to_response());
    }

    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let report_repo = PublicMessageReportRepositoryImpl::new(pool_clone.clone());
    let message_repo = PublicMessageRepositoryImpl::new(pool_clone.clone());

    // Get reports and messages
    let get_message_reports_result = report_repo.get_all_with_executor(&mut *transaction).await;
    let get_messages_result = message_repo
        .get_reported_with_executor(&mut *transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    let reports = match get_message_reports_result {
        Ok(r) => r,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let messages = match get_messages_result {
        Ok(r) => r,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    HttpResponse::Ok().json(PublicMessageReportsResponse {
        code: "PUBLIC_MESSAGE_FETCHED".to_string(),
        message_reports: reports
            .iter()
            .map(|m| m.to_public_message_report_data())
            .collect(),
        messages: messages
            .iter()
            .map(|m| m.to_public_message_data())
            .collect(),
    })
}
