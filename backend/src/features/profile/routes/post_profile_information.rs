use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        profile::{
            helpers::profile::{get_user_by_id, update_user},
            structs::{requests::UserUpdateRequest, responses::UserResponse},
        },
    },
};
use actix_web::{
    post,
    web::{Data, Json, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[post("/me")]
pub async fn post_profile_information(
    body: Json<UserUpdateRequest>,
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

    let mut request_user = match get_user_by_id(&mut transaction, request_claims.user_id).await {
        Ok(user) => match user {
            Some(user) => user,
            None => return HttpResponse::NotFound().json(AppError::UserNotFound.to_response()),
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response());
        }
    };

    request_user.locale = body.locale.clone();
    request_user.theme = body.theme.clone();
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

    let updated_user_result = update_user(&mut transaction, &request_user).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match updated_user_result {
        Ok(_) => HttpResponse::Ok().json(UserResponse {
            code: "PROFILE_UPDATED".to_string(),
            user: request_user.to_user_data(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response())
        }
    }
}
