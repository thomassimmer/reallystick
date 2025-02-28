use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        public_discussions::{
            helpers::{public_message, public_message_report},
            structs::responses::public_message_report::PublicMessageReportsResponse,
        },
    },
};
use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/me")]
pub async fn get_user_message_reports(
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let get_message_reports_result =
        public_message_report::get_user_message_reports(&mut transaction, request_claims.user_id)
            .await;
    let get_messages_result =
        public_message::get_user_reported_messages(&mut transaction, request_claims.user_id).await;

    let messages = match get_messages_result {
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

    match get_message_reports_result {
        Ok(reports) => HttpResponse::Ok().json(PublicMessageReportsResponse {
            code: "PUBLIC_MESSAGE_FETCHED".to_string(),
            message_reports: reports
                .iter()
                .map(|m| m.to_public_message_report_data())
                .collect(),
            messages: messages
                .iter()
                .map(|m| m.to_public_message_data())
                .collect(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::PublicMessageCreation.to_response())
        }
    }
}
