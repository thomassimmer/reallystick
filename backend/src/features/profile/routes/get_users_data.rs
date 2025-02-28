use crate::{
    core::constants::errors::AppError,
    features::profile::{
        helpers::profile::get_users_by_id,
        structs::{
            models::{UserPublicData, UserPublicDataCache},
            requests::GetUserPublicDataRequest,
            responses::UsersResponse,
        },
    },
};
use actix_web::{
    post,
    web::{self, Data, Json},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use uuid::Uuid;

#[post("/")]
pub async fn get_users_data(
    body: Json<GetUserPublicDataRequest>,
    pool: web::Data<PgPool>,
    cache: Data<UserPublicDataCache>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseTransaction.to_response());
        }
    };

    let mut users_in_cache = Vec::<UserPublicData>::new();
    let mut user_ids_to_query = Vec::<Uuid>::new();

    for user_id in body.user_ids.iter() {
        if let Some(user_public_data) = cache.get_value_for_key(user_id).await {
            users_in_cache.push(user_public_data);
        } else {
            user_ids_to_query.push(user_id.to_owned());
        }
    }

    let users = get_users_by_id(&mut transaction, user_ids_to_query).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match users {
        Ok(users) => {
            cache
                .insert_mutiple_keys(
                    users
                        .iter()
                        .map(|u| (u.id, u.to_user_public_data()))
                        .collect(),
                )
                .await;

            users_in_cache.extend(users.iter().map(|u| u.to_user_public_data()));

            HttpResponse::Ok().json(UsersResponse {
                code: "USER_PUBLIC_DATA_FETCHED".to_string(),
                users: users_in_cache,
            })
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response())
        }
    }
}
