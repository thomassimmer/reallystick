use crate::{
    core::{constants::errors::AppError, helpers::mock_now::now},
    features::{
        auth::structs::models::Claims,
        private_discussions::{
            helpers::{
                private_discussion::{self, get_private_discussion_by_users},
                private_discussion_participation::{
                    create_private_discussion_participation,
                    get_private_discussion_participation_by_user_and_discussion,
                },
            },
            structs::{
                models::{
                    private_discussion::PrivateDiscussion,
                    private_discussion_participation::PrivateDiscussionParticipation,
                },
                requests::private_discussion::PrivateDiscussionCreateRequest,
                responses::private_discussion::PrivateDiscussionResponse,
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
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_private_discussion(
    pool: Data<PgPool>,
    body: Json<PrivateDiscussionCreateRequest>,
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
    match get_private_discussion_by_users(&mut *transaction, body.recipient, request_claims.user_id)
        .await
    {
        Ok(r) => if let Some(discussion) = r {
            match get_private_discussion_participation_by_user_and_discussion(
                &mut *transaction,
                request_claims.user_id,
                discussion.id,
            )
            .await
            {
                Ok(r) => match r {
                    Some(participation) => {
                        return HttpResponse::Ok().json(PrivateDiscussionResponse {
                            code: "PRIVATE_DISCUSSION_ALREADY_CREATED".to_string(),
                            discussion: Some(discussion.to_private_discussion_data(
                                Some(participation.color),
                                Some(participation.has_blocked),
                                None,
                                Some(body.recipient),
                                0,
                            )),
                        })
                    }
                    None => {
                        return HttpResponse::InternalServerError().json(
                            AppError::PrivateDiscussionParticipationNotFound.to_response(),
                        )
                    }
                },
                Err(e) => {
                    error!("Error: {}", e);
                    return HttpResponse::InternalServerError()
                        .json(AppError::DatabaseQuery.to_response());
                }
            }
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let discussion = PrivateDiscussion {
        id: Uuid::new_v4(),
        created_at: now(),
    };

    let create_private_discussion_result =
        private_discussion::create_private_discussion(&mut *transaction, &discussion).await;

    if let Err(e) = create_private_discussion_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateDiscussionCreation.to_response());
    }

    let discussion_participation_for_user = PrivateDiscussionParticipation {
        id: Uuid::new_v4(),
        user_id: request_claims.user_id,
        discussion_id: discussion.id,
        color: body.color.clone(),
        created_at: now(),
        has_blocked: false,
    };

    let discussion_participation_for_recipient = PrivateDiscussionParticipation {
        id: Uuid::new_v4(),
        user_id: body.recipient,
        discussion_id: discussion.id,
        color: body.color.clone(),
        created_at: now(),
        has_blocked: false,
    };

    let create_discussion_participation_for_user_result = create_private_discussion_participation(
        &mut *transaction,
        &discussion_participation_for_user,
    )
    .await;

    if let Err(e) = create_discussion_participation_for_user_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateDiscussionParticipationCreation.to_response());
    }

    let create_discussion_participation_for_recipient_result =
        create_private_discussion_participation(
            &mut *transaction,
            &discussion_participation_for_recipient,
        )
        .await;

    if let Err(e) = create_discussion_participation_for_recipient_result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::PrivateDiscussionParticipationCreation.to_response());
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(PrivateDiscussionResponse {
        code: "PRIVATE_DISCUSSION_CREATED".to_string(),
        discussion: Some(discussion.to_private_discussion_data(
            Some(body.color.clone()),
            Some(false),
            None,
            Some(body.recipient),
            0,
        )),
    })
}
