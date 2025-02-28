use crate::{
    core::constants::errors::AppError,
    features::challenges::{
        helpers::challenge::get_challenge_by_id,
        structs::{
            requests::challenge::GetChallengeParams, responses::challenge::ChallengeResponse,
        },
    },
};
use actix_web::{
    get,
    web::{Data, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/{challenge_id}")]
pub async fn get_challenge(pool: Data<PgPool>, params: Path<GetChallengeParams>) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let get_challenge_result = get_challenge_by_id(&mut transaction, params.challenge_id).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match get_challenge_result {
        Ok(r) => match r {
            Some(challenge) => HttpResponse::Ok().json(ChallengeResponse {
                code: "CHALLENGE_FETCHED".to_string(),
                challenge: Some(challenge.to_challenge_data()),
            }),
            None => HttpResponse::NotFound().json(AppError::ChallengeNotFound.to_response()),
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
