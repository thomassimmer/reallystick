use crate::{
    core::constants::errors::AppError,
    features::{
        challenges::{helpers::challenge, structs::responses::challenge::ChallengesResponse},
        profile::structs::models::User,
    },
};
use actix_web::{get, web::Data, HttpResponse, Responder};
use sqlx::PgPool;

#[get("/")]
pub async fn get_challenges(pool: Data<PgPool>, request_user: User) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let get_challenges_result = if request_user.is_admin {
        challenge::get_challenges(&mut transaction).await
    } else {
        challenge::get_created_and_joined_challenges(&mut transaction, request_user.id).await
    };

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match get_challenges_result {
        Ok(challenges) => HttpResponse::Ok().json(ChallengesResponse {
            code: "CHALLENGES_FETCHED".to_string(),
            challenges: challenges.iter().map(|h| h.to_challenge_data()).collect(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
