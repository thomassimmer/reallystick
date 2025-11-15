use crate::{
    core::constants::errors::AppError,
    features::{
        auth::domain::entities::Claims,
        public_discussions::{
            application::dto::responses::public_message::PublicMessagesResponse,
            domain::repositories::public_message_repository::PublicMessageRepository,
            infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl,
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

#[get("/written/")]
pub async fn get_user_written_messages(
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let pool_clone = pool.get_ref().clone();
    let message_repo = PublicMessageRepositoryImpl::new(pool_clone);

    let get_messages_result = message_repo.get_by_creator(request_claims.user_id).await;

    match get_messages_result {
        Ok(messages) => HttpResponse::Ok().json(PublicMessagesResponse {
            code: "PUBLIC_MESSAGE_FETCHED".to_string(),
            messages: messages
                .iter()
                .map(|m| m.to_public_message_data())
                .collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::PublicMessageCreation.to_response())
        }
    }
}
