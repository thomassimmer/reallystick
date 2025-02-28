use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        public_discussions::{
            helpers::public_message::{self},
            structs::responses::public_message::PublicMessagesResponse,
        },
    },
};
use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/written/")]
pub async fn get_user_written_messages(
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let get_messages_result =
        public_message::get_user_written_messages(&**pool, request_claims.user_id).await;

    match get_messages_result {
        Ok(messages) => HttpResponse::Ok().json(PublicMessagesResponse {
            code: "PUBLIC_MESSAGE_FETCHED".to_string(),
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
