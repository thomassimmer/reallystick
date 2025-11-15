use crate::{
    core::constants::errors::AppError,
    features::{
        auth::domain::entities::Claims,
        public_discussions::{
            application::dto::{
                requests::public_message::DeletePublicMessageParams,
                responses::public_message::PublicMessageResponse,
            },
            application::use_cases::delete_public_message::DeletePublicMessageUseCase,
            infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl,
        },
    },
};
use actix_web::{
    delete,
    web::{Data, Query, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[delete("/")]
pub async fn delete_public_message(
    pool: Data<PgPool>,
    query: Query<DeletePublicMessageParams>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let params = query.into_inner();

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
    let message_repo = PublicMessageRepositoryImpl::new(pool_clone.clone());

    let use_case = DeletePublicMessageUseCase::new(message_repo);
    let result = use_case
        .execute(
            params.message_id,
            request_claims.user_id,
            request_claims.is_admin,
            params.deleted_by_admin,
            &mut transaction,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(PublicMessageResponse {
            code: "PUBLIC_MESSAGE_DELETED".to_string(),
            message: None,
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
