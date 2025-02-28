use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        public_discussions::{
            helpers::public_message::{
                self, get_public_message_by_id, update_public_message_reply_count,
            },
            structs::{
                requests::public_message::DeletePublicMessageParams,
                responses::public_message::PublicMessageResponse,
            },
        },
    },
};
use actix_web::{
    delete,
    web::{Data, Query, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

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
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Check if message exists
    let mut public_message = match get_public_message_by_id(&mut *transaction, params.message_id)
        .await
    {
        Ok(r) => match r {
            Some(public_message) => public_message,
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

    // If deleted by creator, check request user is creator
    if !params.deleted_by_admin && public_message.creator != request_claims.user_id {
        return HttpResponse::Unauthorized()
            .json(AppError::PublicMessageDeletionNotDoneByCreator.to_response());
    }

    // If deleted by admin, check request user is admin
    if params.deleted_by_admin && !request_claims.is_admin {
        return HttpResponse::Unauthorized()
            .json(AppError::PublicMessageDeletionNotDoneByAdmin.to_response());
    }

    public_message.deleted_by_admin = params.deleted_by_admin;
    public_message.deleted_by_creator = !params.deleted_by_admin;

    let delete_public_message_result =
        public_message::delete_public_message(&mut *transaction, &public_message).await;

    if let Err(e) = delete_public_message_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PublicMessageDeletion.to_response());
    }

    if let Some(public_message_replying_to) = public_message.replies_to {
        if let Ok(Some(mut message)) =
            get_public_message_by_id(&mut *transaction, public_message_replying_to).await
        {
            message.reply_count -= 1;

            let update_public_message_result =
                update_public_message_reply_count(&mut *transaction, &message).await;

            if let Err(e) = update_public_message_result {
                eprintln!("Error: {}", e);
                return HttpResponse::InternalServerError()
                    .json(AppError::PublicMessageUpdate.to_response());
            }
        }
    }

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PublicMessageResponse {
        code: "PUBLIC_MESSAGE_DELETED".to_string(),
        message: None,
    })
}
