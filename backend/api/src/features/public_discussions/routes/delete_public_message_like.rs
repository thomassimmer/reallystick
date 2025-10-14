use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        public_discussions::{
            helpers::{
                public_message::{get_public_message_by_id, update_public_message_like_count},
                public_message_like::{self, get_public_message_like_by_message_id_and_user_id},
            },
            structs::{
                requests::public_message_like::DeletePublicMessageLikeParams,
                responses::public_message_like::PublicMessageLikeResponse,
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

    // Check if message exists
    let mut public_message = match get_public_message_by_id(&mut *transaction, params.message_id)
        .await
    {
        Ok(r) => match r {
            Some(r) => r,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::PublicMessageNotFound.to_response());
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Check if message exists
    let public_message_like = match get_public_message_like_by_message_id_and_user_id(
        &mut *transaction,
        params.message_id,
        request_claims.user_id,
    )
    .await
    {
        Ok(r) => match r {
            Some(r) => r,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::PublicMessageNotFound.to_response());
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let delete_public_message_result =
        public_message_like::delete_public_message_like(&mut *transaction, public_message_like.id)
            .await;

    if let Err(e) = delete_public_message_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PublicMessageLikeDeletion.to_response());
    }

    public_message.like_count -= 1;

    let update_public_message_result =
        update_public_message_like_count(&mut *transaction, &public_message).await;

    if let Err(e) = update_public_message_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PublicMessageUpdate.to_response());
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PublicMessageLikeResponse {
        code: "PUBLIC_MESSAGE_LIKE_DELETED".to_string(),
    })
}
