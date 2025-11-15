// Delete habit category route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::habits::application::dto::requests::habit_category::GetHabitCategoryParams;
use crate::features::habits::application::dto::responses::habit::HabitResponse;
use crate::features::habits::application::use_cases::delete_habit_category::DeleteHabitCategoryUseCase;
use crate::features::habits::infrastructure::repositories::habit_category_repository::HabitCategoryRepositoryImpl;
use actix_web::web::{Data, Path, ReqData};
use actix_web::{delete, HttpResponse, Responder};
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

    // Create repository and use case
    let pool_clone = pool.get_ref().clone();
    let category_repo = HabitCategoryRepositoryImpl::new(pool_clone);
    let delete_category_use_case = DeleteHabitCategoryUseCase::new(category_repo);

    // Execute use case
    let result = delete_category_use_case
        .execute(params.habit_category_id, &mut transaction)
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(HabitResponse {
            code: "HABIT_CATEGORY_DELETED".to_string(),
            habit: None,
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
