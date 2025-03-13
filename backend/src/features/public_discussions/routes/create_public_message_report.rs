use crate::{
    core::{constants::errors::AppError, helpers::mock_now::now},
    features::{
        auth::structs::models::Claims,
        public_discussions::{
            helpers::{public_message::get_public_message_by_id, public_message_report},
            structs::{
                models::{
                    public_message::PUBLIC_MESSAGE_CONTENT_MAX_LENGTH,
                    public_message_report::PublicMessageReport,
                },
                requests::public_message_report::PublicMessageReportCreateRequest,
                responses::public_message_report::PublicMessageReportResponse,
            },
        },
    },
};
use actix_web::{
    post,
    web::{Data, Json, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_public_message_report(
    pool: Data<PgPool>,
    body: Json<PublicMessageReportCreateRequest>,
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

    // Check if message exists
    match get_public_message_by_id(&mut *transaction, body.message_id).await {
        Ok(r) => {
            if r.is_none() {
                return HttpResponse::NotFound()
                    .json(AppError::PublicMessageNotFound.to_response());
            }
        }
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Check content size
    if body.reason.len() > PUBLIC_MESSAGE_CONTENT_MAX_LENGTH {
        return HttpResponse::BadRequest()
            .json(AppError::PublicMessageContentTooLong.to_response());
    } else if body.reason.is_empty() {
        return HttpResponse::BadRequest().json(AppError::PublicMessageContentEmpty.to_response());
    }

    let public_message_report = PublicMessageReport {
        id: Uuid::new_v4(),
        message_id: body.message_id,
        reporter: request_claims.user_id,
        created_at: now(),
        reason: body.reason.to_owned(),
    };

    let create_public_message_result = public_message_report::create_public_message_report(
        &mut *transaction,
        public_message_report.clone(),
    )
    .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match create_public_message_result {
        Ok(_) => HttpResponse::Ok().json(PublicMessageReportResponse {
            code: "PUBLIC_MESSAGE_REPORT_CREATED".to_string(),
            message_report: Some(public_message_report.to_public_message_report_data()),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::PublicMessageReportCreation.to_response())
        }
    }
}
