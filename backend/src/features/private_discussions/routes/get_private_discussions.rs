use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        private_discussions::{
            helpers::{private_discussion, private_discussion_participation, private_message},
            structs::responses::private_discussion::PrivateDiscussionsResponse,
        },
    },
};
use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/")]
pub async fn get_private_discussions(
    pool: Data<PgPool>,
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

    let discussion_participations =
        match private_discussion_participation::get_user_private_discussion_participations(
            &mut transaction,
            request_claims.user_id,
        )
        .await
        {
            Ok(r) => r,
            Err(e) => {
                eprintln!("Error: {}", e);
                return HttpResponse::InternalServerError()
                    .json(AppError::DatabaseQuery.to_response());
            }
        };

    let discussions = match private_discussion::get_private_discussions_from_ids(
        &mut transaction,
        discussion_participations
            .iter()
            .map(|p| p.discussion_id)
            .collect(),
    )
    .await
    {
        Ok(r) => r,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let recipients = match private_discussion_participation::get_private_discussions_recipients(
        &mut transaction,
        discussions.iter().map(|d| d.id).collect(),
        request_claims.user_id,
    )
    .await
    {
        Ok(r) => r,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let messages = match private_message::get_last_messages_for_discussions(
        &mut transaction,
        discussions.iter().map(|d| d.id).collect(),
    )
    .await
    {
        Ok(r) => r,
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

    HttpResponse::Ok().json(PrivateDiscussionsResponse {
        code: "PRIVATE_DISCUSSIONS_FETCHED".to_string(),
        discussions: discussions
            .iter()
            .map(|d| {
                let participation = discussion_participations
                    .iter()
                    .filter(|p| p.discussion_id == d.id)
                    .next();

                let last_message = messages
                    .clone()
                    .into_iter()
                    .filter(|m| m.discussion_id == d.id)
                    .next();

                let recipient = recipients.iter().filter(|p| p.discussion_id == d.id).next();

                d.to_private_discussion_data(
                    participation.and_then(|p| Some(p.color.clone())),
                    participation.and_then(|p| Some(p.has_blocked)),
                    last_message.and_then(|m| Some(m.to_private_message_data())),
                    recipient.and_then(|r| Some(r.user_id)),
                )
            })
            .collect(),
    })
}
