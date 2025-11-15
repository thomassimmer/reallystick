use crate::{
    core::constants::errors::AppError,
    features::{
        auth::domain::entities::Claims,
        public_discussions::{
            application::dto::{
                requests::public_message_like::DeletePublicMessageLikeParams,
                responses::public_message_like::PublicMessageLikeResponse,
            },
            application::use_cases::delete_public_message_like::DeletePublicMessageLikeUseCase,
            infrastructure::repositories::{
                public_message_like_repository::PublicMessageLikeRepositoryImpl,
                public_message_repository::PublicMessageRepositoryImpl,
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
use tracing::error;

#[delete("/{message_id}")]
pub async fn delete_public_message_like(
    pool: Data<PgPool>,
    params: Path<DeletePublicMessageLikeParams>,
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
    let like_repo = PublicMessageLikeRepositoryImpl::new(pool_clone.clone());
    let message_repo = PublicMessageRepositoryImpl::new(pool_clone.clone());

    let use_case = DeletePublicMessageLikeUseCase::new(like_repo, message_repo);
    let result = use_case
        .execute(params.message_id, request_claims.user_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(PublicMessageLikeResponse {
            code: "PUBLIC_MESSAGE_LIKE_DELETED".to_string(),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
