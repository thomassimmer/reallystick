use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        public_discussions::{
            helpers::public_message_report::{self, get_public_message_report_by_id},
            structs::{
                requests::public_message_report::DeletePublicMessageReportParams,
                responses::public_message_report::PublicMessageReportResponse,
            },
        },
    },
};
use actix_web::{
    delete,
    web::{Data, Path, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[delete("/{message_report_id}")]
pub async fn delete_public_message_report(
    pool: Data<PgPool>,
    params: Path<DeletePublicMessageReportParams>,
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

    // Check if message report exists
    match get_public_message_report_by_id(&mut transaction, params.message_report_id).await {
        Ok(r) => match r {
            Some(public_message_report) => {
                if public_message_report.reporter != request_claims.user_id {
                    return HttpResponse::Unauthorized()
                        .json(AppError::PublicMessageReportReporterIsNotRequestUser.to_response());
                }
            }
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::PublicMessageReportNotFound.to_response());
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let delete_public_message_result = public_message_report::delete_public_message_report(
        &mut transaction,
        params.message_report_id,
    )
    .await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match delete_public_message_result {
        Ok(_) => HttpResponse::Ok().json(PublicMessageReportResponse {
            code: "PUBLIC_MESSAGE_REPORT_DELETED".to_string(),
            message_report: None,
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::PublicMessageReportDeletion.to_response())
        }
    }
}
