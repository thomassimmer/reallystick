// Update unit route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::habits::application::dto::requests::unit::{
    UnitUpdateRequest, UpdateUnitParams,
};
use crate::features::habits::application::dto::responses::unit::UnitResponse;
use crate::features::habits::application::use_cases::update_unit::UpdateUnitUseCase;
use crate::features::habits::infrastructure::repositories::unit_repository::UnitRepositoryImpl;
use actix_web::web::{Data, Json, Path, ReqData};
use actix_web::{put, HttpResponse, Responder};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;

#[put("/{unit_id}")]
pub async fn update_unit(
    pool: Data<PgPool>,
    params: Path<UpdateUnitParams>,
    body: Json<UnitUpdateRequest>,
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

    // Create repository
    let pool_clone = pool.get_ref().clone();
    let unit_repo = UnitRepositoryImpl::new(pool_clone.clone());

    // Get existing unit
    let mut unit = match unit_repo
        .get_by_id_with_executor(params.unit_id, &mut *transaction)
        .await
    {
        Ok(Some(u)) => u,
        Ok(None) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::NotFound().json(AppError::UnitNotFound.to_response());
        }
        Err(_) => {
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    // Update unit fields
    unit.short_name = json!(body.short_name).to_string();

    // Execute use case
    let update_unit_use_case = UpdateUnitUseCase::new(unit_repo);
    let result = update_unit_use_case.execute(&unit, &mut transaction).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(UnitResponse {
            code: "UNIT_UPDATED".to_string(),
            unit: Some(unit.to_unit_data()),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
