use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        habits::{
            helpers::habit_category::delete_habit_category_by_id,
            structs::{
                requests::habit_category::GetHabitCategoryParams, responses::habit::HabitResponse,
            },
        },
    },
};
use actix_web::{
    delete,
    web::{Data, Path, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[delete("/{habit_category_id}")]
pub async fn delete_habit_category(
    pool: Data<PgPool>,
    params: Path<GetHabitCategoryParams>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    if !request_claims.is_admin {
        return HttpResponse::Forbidden().body("Access denied");
    }

    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let delete_habit_category_result =
        delete_habit_category_by_id(&mut *transaction, params.habit_category_id).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match delete_habit_category_result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                HttpResponse::Ok().json(HabitResponse {
                    code: "HABIT_CATEGORY_DELETED".to_string(),
                    habit: None,
                })
            } else {
                HttpResponse::NotFound().json(AppError::HabitCategoryNotFound.to_response())
            }
        }
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::HabitCategoryDelete.to_response())
        }
    }
}
