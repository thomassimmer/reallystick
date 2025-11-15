use crate::{
    core::constants::errors::AppError,
    features::{
        auth::domain::entities::Claims,
        public_discussions::{
            application::dto::responses::public_message::PublicMessagesResponse,
            domain::repositories::public_message_like_repository::PublicMessageLikeRepository,
            infrastructure::repositories::public_message_like_repository::PublicMessageLikeRepositoryImpl,
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

#[get("/liked/")]
pub async fn get_user_liked_messages(
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let pool_clone = pool.get_ref().clone();
    let like_repo = PublicMessageLikeRepositoryImpl::new(pool_clone);

    let get_messages_result = like_repo.get_messages_by_user(request_claims.user_id).await;

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
