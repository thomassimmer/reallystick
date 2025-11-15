// Get units route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::habits::application::dto::responses::unit::UnitsResponse;
use crate::features::habits::application::use_cases::get_units::GetUnitsUseCase;
use crate::features::habits::infrastructure::repositories::unit_repository::UnitRepositoryImpl;
use actix_web::web::Data;
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_units(pool: Data<PgPool>) -> impl Responder {
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
    let unit_repo = UnitRepositoryImpl::new(pool_clone);
    let get_units_use_case = GetUnitsUseCase::new(unit_repo);

    // Execute use case
    let result = get_units_use_case.execute(&mut transaction).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(units) => HttpResponse::Ok().json(UnitsResponse {
            code: "UNITS_FETCHED".to_string(),
            units: units.iter().map(|u| u.to_unit_data()).collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
