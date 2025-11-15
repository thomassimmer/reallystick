// Create private discussion route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::core::helpers::mock_now::now;
use crate::features::auth::domain::entities::Claims;
use crate::features::private_discussions::application::use_cases::create_private_discussion::CreatePrivateDiscussionUseCase;
use crate::features::private_discussions::domain::entities::private_discussion::PrivateDiscussion;
use crate::features::private_discussions::domain::entities::private_discussion_participation::PrivateDiscussionParticipation;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_participation_repository::PrivateDiscussionParticipationRepositoryImpl;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_repository::PrivateDiscussionRepositoryImpl;
use crate::features::private_discussions::application::dto::requests::private_discussion::PrivateDiscussionCreateRequest;
use crate::features::private_discussions::application::dto::responses::private_discussion::PrivateDiscussionResponse;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
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

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let discussion_repo = PrivateDiscussionRepositoryImpl::new(pool_clone.clone());
    let participation_repo = PrivateDiscussionParticipationRepositoryImpl::new(pool_clone.clone());

    // Check if discussion already exists
    match discussion_repo
        .get_by_users_with_executor(body.recipient, request_claims.user_id, &mut *transaction)
        .await
    {
        Ok(Some(existing_discussion)) => {
            // Check if user has participation
            match participation_repo
                .get_by_user_and_discussion_with_executor(
                    request_claims.user_id,
                    existing_discussion.id,
                    &mut *transaction,
                )
                .await
            {
                Ok(Some(participation)) => {
                    if let Err(e) = transaction.rollback().await {
                        error!("Error rolling back: {}", e);
                    }
                    return HttpResponse::Ok().json(PrivateDiscussionResponse {
                        code: "PRIVATE_DISCUSSION_ALREADY_CREATED".to_string(),
                        discussion: Some(existing_discussion.to_private_discussion_data(
                            Some(participation.color),
                            Some(participation.has_blocked),
                            None,
                            Some(body.recipient),
                            0,
                        )),
                    });
                }
                Ok(None) => {
                    if let Err(e) = transaction.rollback().await {
                        error!("Error rolling back: {}", e);
                    }
                    return HttpResponse::InternalServerError()
                        .json(AppError::PrivateDiscussionParticipationNotFound.to_response());
                }
                Err(_) => {
                    if let Err(e) = transaction.rollback().await {
                        error!("Error rolling back: {}", e);
                    }
                    return HttpResponse::InternalServerError()
                        .json(AppError::DatabaseQuery.to_response());
                }
            }
        }
        Ok(None) => {}
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    }

    // Create new discussion
    let discussion = PrivateDiscussion {
        id: Uuid::new_v4(),
        created_at: now(),
    };

    let participation1 = PrivateDiscussionParticipation {
        id: Uuid::new_v4(),
        user_id: request_claims.user_id,
        discussion_id: discussion.id,
        color: "blue".to_string(),
        created_at: now(),
        has_blocked: false,
    };

    let participation2 = PrivateDiscussionParticipation {
        id: Uuid::new_v4(),
        user_id: body.recipient,
        discussion_id: discussion.id,
        color: "blue".to_string(),
        created_at: now(),
        has_blocked: false,
    };

    // Execute use case
    let create_discussion_use_case =
        CreatePrivateDiscussionUseCase::new(discussion_repo, participation_repo);
    let result = create_discussion_use_case
        .execute(
            &discussion,
            &participation1,
            &participation2,
            &mut transaction,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(PrivateDiscussionResponse {
            code: "PRIVATE_DISCUSSION_CREATED".to_string(),
            discussion: Some(discussion.to_private_discussion_data(
                Some(participation1.color),
                Some(participation1.has_blocked),
                None,
                Some(body.recipient),
                0,
            )),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
