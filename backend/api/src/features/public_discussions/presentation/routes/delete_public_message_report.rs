use crate::{
    core::constants::errors::AppError,
    features::{
        auth::domain::entities::Claims,
        public_discussions::{
            application::dto::{
                requests::public_message_report::DeletePublicMessageReportParams,
                responses::public_message_report::PublicMessageReportResponse,
            },
            application::use_cases::delete_public_message_report::DeletePublicMessageReportUseCase,
            infrastructure::repositories::public_message_report_repository::PublicMessageReportRepositoryImpl,
        },
    },
};
use actix_web::{
    delete,
    web::{Data, Path, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[delete("/{message_report_id}")]
pub async fn delete_public_message_report(
    pool: Data<PgPool>,
    params: Path<DeletePublicMessageReportParams>,
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

    // Create repositories and use case
    let pool_clone = pool.get_ref().clone();
    let report_repo = PublicMessageReportRepositoryImpl::new(pool_clone.clone());

    let use_case = DeletePublicMessageReportUseCase::new(report_repo);
    let result = use_case
        .execute(
            params.message_report_id,
            request_claims.user_id,
            &mut transaction,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(PublicMessageReportResponse {
            code: "PUBLIC_MESSAGE_REPORT_DELETED".to_string(),
            message_report: None,
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
