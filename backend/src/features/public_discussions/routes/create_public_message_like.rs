use crate::{
    core::{constants::errors::AppError, helpers::mock_now::now},
    features::{
        auth::structs::models::Claims,
        public_discussions::{
            helpers::{
                public_message::{get_public_message_by_id, update_public_message_like_count},
                public_message_like,
            },
            structs::{
                models::public_message_like::PublicMessageLike,
                requests::public_message_like::PublicMessageLikeCreateRequest,
                responses::public_message_like::PublicMessageLikeResponse,
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
use uuid::Uuid;

#[post("/")]
pub async fn create_public_message_like(
    pool: Data<PgPool>,
    body: Json<PublicMessageLikeCreateRequest>,
    request_claims: ReqData<Claims>,
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
    let mut public_message = match get_public_message_by_id(&mut transaction, body.message_id).await
    {
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

    let public_message_like = PublicMessageLike {
        id: Uuid::new_v4(),
        message_id: body.message_id,
        user_id: request_claims.user_id,
        created_at: now(),
    };

    let create_public_message_like_result =
        public_message_like::create_public_message_like(&mut transaction, public_message_like)
            .await;

    if let Err(e) = create_public_message_like_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PublicMessageLikeCreation.to_response());
    }

    public_message.like_count += 1;

    let update_public_message_result =
        update_public_message_like_count(&mut transaction, &public_message).await;

    if let Err(e) = update_public_message_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PublicMessageUpdate.to_response());
    }

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PublicMessageLikeResponse {
        code: "PUBLIC_MESSAGE_LIKE_CREATED".to_string(),
    })
}
