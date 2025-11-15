// Update private discussion participation route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::private_discussions::application::use_cases::update_private_discussion_participation::UpdatePrivateDiscussionParticipationUseCase;
use crate::features::private_discussions::infrastructure::repositories::private_discussion_participation_repository::PrivateDiscussionParticipationRepositoryImpl;
use crate::features::private_discussions::application::dto::requests::private_discussion_participation::{
    PrivateDiscussionParticipationUpdateRequest, UpdatePrivateDiscussionParticipationParams,
};
use crate::features::private_discussions::application::dto::responses::private_discussion_participation::PrivateDiscussionParticipationResponse;
use actix_web::web::{Data, Json, Path, ReqData};
use actix_web::{put, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

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
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Create repository
    let pool_clone = pool.get_ref().clone();
    let participation_repo = PrivateDiscussionParticipationRepositoryImpl::new(pool_clone.clone());

    // Get existing participation
    let mut participation = match participation_repo
        .get_by_user_and_discussion_with_executor(
            request_claims.user_id,
            params.discussion_id,
            &mut *transaction,
        )
        .await
    {
        Ok(Some(p)) => p,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound()
                .json(AppError::PrivateDiscussionParticipationNotFound.to_response());
        }
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Update participation fields
    participation.color = body.color.clone();
    participation.has_blocked = body.has_blocked;

    // Execute use case
    let update_participation_use_case =
        UpdatePrivateDiscussionParticipationUseCase::new(participation_repo);
    let result = update_participation_use_case
        .execute(&participation, request_claims.user_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(PrivateDiscussionParticipationResponse {
            code: "PRIVATE_DISCUSSION_PARTICIPATION_UPDATED".to_string(),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
