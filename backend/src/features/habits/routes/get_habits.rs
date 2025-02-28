use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        habits::{helpers::habit, structs::responses::habit::HabitsResponse},
    },
};
use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[get("/")]
pub async fn get_habits(pool: Data<PgPool>, request_claims: ReqData<Claims>) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let get_habits_result = if request_claims.is_admin {
        habit::get_habits(&mut transaction).await
    } else {
        habit::get_reviewed_and_personnal_habits(&mut transaction, request_claims.user_id).await
    };

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match get_habits_result {
        Ok(habits) => HttpResponse::Ok().json(HabitsResponse {
            code: "HABITS_FETCHED".to_string(),
            habits: habits.iter().map(|h| h.to_habit_data()).collect(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
