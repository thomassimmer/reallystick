// Get users data by id route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::profile::application::dto::requests::GetUserPublicDataByIdRequest;
use crate::features::profile::application::dto::responses::UsersResponse;
use crate::features::profile::domain::entities::{UserPublicData, UserPublicDataCache};
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use actix_web::web::{Data, Json};
use actix_web::{post, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn get_users_data_by_id(
    body: Json<GetUserPublicDataByIdRequest>,
    pool: Data<PgPool>,
    cache: Data<UserPublicDataCache>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let mut users_in_cache = Vec::<UserPublicData>::new();
    let mut user_ids_to_query = Vec::<Uuid>::new();

    // Check cache first
    for user_id in body.user_ids.iter() {
        if let Some(user_public_data) = cache.get_value_for_key(*user_id).await {
            users_in_cache.push(user_public_data);
        } else {
            user_ids_to_query.push(user_id.to_owned());
        }
    }

    // Query database for users not in cache
    let pool_clone = pool.get_ref().clone();
    let user_repo = UserRepositoryImpl::new(pool_clone);
    let users = match user_repo
        .get_by_ids_with_executor(user_ids_to_query.clone(), &mut *transaction)
        .await
    {
        Ok(users) => users,
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response());
        }
    };

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    // Update cache with fetched users
    cache
        .insert_mutiple_keys(
            users
                .iter()
                .map(|u| (u.id, u.to_user_public_data()))
                .collect(),
        )
        .await;

    // Add fetched users to response
    users_in_cache.extend(users.iter().map(|u| u.to_user_public_data()));

    HttpResponse::Ok().json(UsersResponse {
        code: "USER_PUBLIC_DATA_FETCHED".to_string(),
        users: users_in_cache,
    })
}
