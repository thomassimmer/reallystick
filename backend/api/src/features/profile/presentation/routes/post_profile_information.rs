// Update profile information route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::profile::application::dto::requests::UserUpdateRequest;
use crate::features::profile::application::dto::responses::UserResponse;
use crate::features::profile::application::use_cases::get_profile::GetProfileUseCase;
use crate::features::profile::application::use_cases::update_profile::UpdateProfileUseCase;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use crate::features::profile::infrastructure::services::user_event_service::UserEventService;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
use redis::Client;
use sqlx::PgPool;
use tracing::error;

#[post("/me")]
pub async fn post_profile_information(
    body: Json<UserUpdateRequest>,
    pool: Data<PgPool>,
    redis_client: Data<Client>,
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
    let user_repo = UserRepositoryImpl::new(pool_clone.clone());

    // Get existing user
    let user_repo_for_get = UserRepositoryImpl::new(pool_clone.clone());
    let get_profile_use_case = GetProfileUseCase::new(user_repo_for_get);
    let mut request_user = match get_profile_use_case
        .execute(request_claims.user_id, &mut transaction)
        .await
    {
        Ok(Some(user)) => user,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::UserNotFound.to_response());
        }
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response());
        }
    };

    // Update user fields from request
    request_user.locale = body.locale.clone();
    request_user.theme = body.theme.clone();
    request_user.timezone = body.timezone.clone();
    request_user.age_category = body.age_category.clone();
    request_user.gender = body.gender.clone();
    request_user.continent = body.continent.clone();
    request_user.country = body.country.clone();
    request_user.region = body.region.clone();
    request_user.activity = body.activity.clone();
    request_user.financial_situation = body.financial_situation.clone();
    request_user.lives_in_urban_area = body.lives_in_urban_area;
    request_user.relationship_status = body.relationship_status.clone();
    request_user.level_of_education = body.level_of_education.clone();
    request_user.has_children = body.has_children;
    request_user.has_seen_questions = body.has_seen_questions;
    request_user.notifications_enabled = body.notifications_enabled;
    request_user.notifications_for_private_messages_enabled =
        body.notifications_for_private_messages_enabled;
    request_user.notifications_for_public_message_liked_enabled =
        body.notifications_for_public_message_liked_enabled;
    request_user.notifications_for_public_message_replies_enabled =
        body.notifications_for_public_message_replies_enabled;
    request_user.notifications_user_duplicated_your_challenge_enabled =
        body.notifications_user_duplicated_your_challenge_enabled;
    request_user.notifications_user_joined_your_challenge_enabled =
        body.notifications_user_joined_your_challenge_enabled;

    // Execute update use case
    let update_profile_use_case = UpdateProfileUseCase::new(user_repo);
    let result = update_profile_use_case
        .execute(&request_user, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => {
            // Publish user updated event
            let user_event_service = UserEventService::new(redis_client);
            if let Err(e) = user_event_service
                .publish_user_updated_event(request_user.clone())
                .await
            {
                error!("Error publishing user_updated event: {}", e);
                // Don't fail the request if Redis publish fails
            }

            HttpResponse::Ok().json(UserResponse {
                code: "PROFILE_UPDATED".to_string(),
                user: request_user.to_user_data(),
            })
        }
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response())
        }
    }
}
