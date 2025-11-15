use crate::{
    core::{constants::errors::AppError, helpers::mock_now::now},
    features::{
        auth::domain::entities::Claims,
        public_discussions::{
            application::dto::{
                requests::public_message::{PublicMessageUpdateRequest, UpdatePublicMessageParams},
                responses::public_message::PublicMessageResponse,
            },
            application::use_cases::update_public_message::UpdatePublicMessageUseCase,
            infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl,
        },
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[put("/{message_id}")]
pub async fn update_public_message(
    pool: Data<PgPool>,
    params: Path<UpdatePublicMessageParams>,
    body: Json<PublicMessageUpdateRequest>,
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

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let message_repo = PublicMessageRepositoryImpl::new(pool_clone.clone());

    // Get existing message
    let mut public_message = match message_repo
        .get_by_id_with_executor(params.message_id, &mut *transaction)
        .await
    {
        Ok(Some(m)) => m,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::PublicMessageNotFound.to_response());
        }
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    public_message.content = body.content.to_owned();
    public_message.updated_at = Some(now());

    let use_case = UpdatePublicMessageUseCase::new(message_repo);
    let result = use_case
        .execute(&public_message, request_claims.user_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(PublicMessageResponse {
            code: "PUBLIC_MESSAGE_UPDATED".to_string(),
            message: Some(public_message.to_public_message_data()),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
