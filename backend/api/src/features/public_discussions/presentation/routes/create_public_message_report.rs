use crate::{
    core::{constants::errors::AppError, helpers::mock_now::now},
    features::{
        auth::domain::entities::Claims,
        public_discussions::{
            application::dto::{
                requests::public_message_report::PublicMessageReportCreateRequest,
                responses::public_message_report::PublicMessageReportResponse,
            },
            application::use_cases::create_public_message_report::CreatePublicMessageReportUseCase,
            domain::entities::public_message_report::PublicMessageReport,
            infrastructure::repositories::{
                public_message_report_repository::PublicMessageReportRepositoryImpl,
                public_message_repository::PublicMessageRepositoryImpl,
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

    let body = body.into_inner();

    let public_message_report = PublicMessageReport {
        id: Uuid::new_v4(),
        message_id: body.message_id,
        reporter: request_claims.user_id,
        created_at: now(),
        reason: body.reason.to_owned(),
    };

    // Create repositories and use case
    let pool_clone = pool.get_ref().clone();
    let report_repo = PublicMessageReportRepositoryImpl::new(pool_clone.clone());
    let message_repo = PublicMessageRepositoryImpl::new(pool_clone.clone());

    let use_case = CreatePublicMessageReportUseCase::new(report_repo, message_repo);
    let result = use_case
        .execute(&public_message_report, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(PublicMessageReportResponse {
            code: "PUBLIC_MESSAGE_REPORT_CREATED".to_string(),
            message_report: Some(public_message_report.to_public_message_report_data()),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
