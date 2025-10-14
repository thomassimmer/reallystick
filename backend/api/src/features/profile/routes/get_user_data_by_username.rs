use crate::{
    core::constants::errors::AppError,
    features::profile::{
        helpers::profile::get_user_by_username,
        structs::{requests::GetUserPublicDataByUsernameRequest, responses::UserPublicResponse},
    },
};
use actix_web::{
    post,
    web::{self, Json},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[post("/by-username/")]
pub async fn get_user_data_by_username(
    body: Json<GetUserPublicDataByUsernameRequest>,
    pool: web::Data<PgPool>,
) -> impl Responder {
    let user = get_user_by_username(&**pool, &body.username.to_lowercase()).await;

    match user {
        Ok(user) => match user {
            Some(u) => HttpResponse::Ok().json(UserPublicResponse {
                code: "USER_PUBLIC_DATA_FETCHED".to_string(),
                user: u.to_user_public_data(),
            }),
            None => HttpResponse::NotFound().json(AppError::UserNotFound.to_response()),
        },
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
