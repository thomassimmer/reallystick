use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        private_discussions::{
            helpers::private_discussion_participation::{
                self, get_private_discussion_participation_by_user_and_discussion,
            },
            structs::{
                requests::private_discussion_participation::{
                    PrivateDiscussionParticipationUpdateRequest,
                    UpdatePrivateDiscussionParticipationParams,
                },
                responses::private_discussion_participation::PrivateDiscussionParticipationResponse,
            },
        },
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[put("/{discussion_id}")]
pub async fn update_private_discussion_participation(
    pool: Data<PgPool>,
    params: Path<UpdatePrivateDiscussionParticipationParams>,
    body: Json<PrivateDiscussionParticipationUpdateRequest>,
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

    let mut participation = match get_private_discussion_participation_by_user_and_discussion(
        &mut *transaction,
        request_claims.user_id,
        params.discussion_id,
    )
    .await
    {
        Ok(r) => match r {
            Some(r) => r,
            None => {
                return HttpResponse::NotFound()
                    .json(AppError::PrivateDiscussionParticipationNotFound.to_response());
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    participation.color = body.color.clone();
    participation.has_blocked = body.has_blocked;

    let update_private_discussion_participation_result =
        private_discussion_participation::update_private_discussion_participation(
            &mut *transaction,
            &participation,
        )
        .await;

    if let Err(e) = update_private_discussion_participation_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateDiscussionParticipationUpdate.to_response());
    }

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PrivateDiscussionParticipationResponse {
        code: "PRIVATE_DISCUSSION_PARTICIPATION_UPDATED".to_string(),
    })
}
