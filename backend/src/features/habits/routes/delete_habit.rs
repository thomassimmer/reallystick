use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        habits::{
            helpers::habit::delete_habit_by_id,
            structs::{requests::habit::GetHabitParams, responses::habit::HabitResponse},
        },
    },
};
use actix_web::{
    delete,
    web::{Data, Path, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[delete("/{habit_id}")]
pub async fn delete_habit(
    pool: Data<PgPool>,
    params: Path<GetHabitParams>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    if !request_claims.is_admin {
        return HttpResponse::Forbidden().body("Access denied");
    }

    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let delete_habit_result = delete_habit_by_id(&mut *transaction, params.habit_id).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match delete_habit_result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                HttpResponse::Ok().json(HabitResponse {
                    code: "HABIT_DELETED".to_string(),
                    habit: None,
                })
            } else {
                HttpResponse::NotFound().json(AppError::HabitNotFound.to_response())
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::HabitDelete.to_response())
        }
    }
}
