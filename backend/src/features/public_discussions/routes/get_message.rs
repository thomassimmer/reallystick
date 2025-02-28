use crate::{
    core::constants::errors::AppError,
    features::public_discussions::{
        helpers::public_message::get_public_message_by_id,
        structs::{
            requests::public_message::GetPublicMessageParams,
            responses::public_message::PublicMessageResponse,
        },
    },
};
use actix_web::{
    get,
    web::{Data, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/{message_id}")]
pub async fn get_message(
    pool: Data<PgPool>,
    params: Path<GetPublicMessageParams>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Check if message exists
    let message = match get_public_message_by_id(&mut transaction, params.message_id).await {
        Ok(r) => match r {
            Some(r) => r,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::PublicMessageNotFound.to_response());
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PublicMessageResponse {
        code: "PUBLIC_MESSAGE_FETCHED".to_string(),
        message: Some(message.to_public_message_data()),
    })
}
