// Create unit route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::domain::entities::Claims;
use crate::features::habits::application::dto::requests::unit::UnitCreateRequest;
use crate::features::habits::application::dto::responses::unit::UnitResponse;
use crate::features::habits::application::use_cases::create_unit::CreateUnitUseCase;
use crate::features::habits::domain::entities::unit::Unit;
use crate::features::habits::infrastructure::repositories::unit_repository::UnitRepositoryImpl;
use actix_web::web::{Data, Json, ReqData};
use actix_web::{post, HttpResponse, Responder};
use chrono::Utc;
use serde_json::json;
use sqlx::PgPool;
use tracing::error;
use uuid::Uuid;

#[post("/")]
pub async fn create_unit(
    pool: Data<PgPool>,
    body: Json<UnitCreateRequest>,
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
    let unit_repo = UnitRepositoryImpl::new(pool_clone);
    let create_unit_use_case = CreateUnitUseCase::new(unit_repo);

    // Create unit entity
    let unit = Unit {
        id: Uuid::new_v4(),
        short_name: json!(body.short_name).to_string(),
        long_name: json!(body.long_name).to_string(),
        created_at: Utc::now(),
    };

    // Execute use case
    let result = create_unit_use_case.execute(&unit, &mut transaction).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(_) => HttpResponse::Ok().json(UnitResponse {
            code: "UNIT_CREATED".to_string(),
            unit: Some(unit.to_unit_data()),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
