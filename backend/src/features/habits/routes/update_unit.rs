use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        habits::{
            helpers::unit::{self, get_unit_by_id},
            structs::{
                requests::unit::{UnitUpdateRequest, UpdateUnitParams},
                responses::unit::UnitResponse,
            },
        },
    },
};
use actix_web::{
    put,
    web::{Data, Json, Path, ReqData},
    HttpResponse, Responder,
};
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

    let get_unit_result = get_unit_by_id(&mut *transaction, params.unit_id).await;

    let mut unit = match get_unit_result {
        Ok(r) => match r {
            Some(unit) => unit,
            None => return HttpResponse::NotFound().json(AppError::UnitNotFound.to_response()),
        },
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    unit.short_name = json!(body.short_name).to_string();

    let update_unit_result = unit::update_unit(&mut *transaction, &unit).await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match update_unit_result {
        Ok(_) => HttpResponse::Ok().json(UnitResponse {
            code: "UNIT_UPDATED".to_string(),
            unit: Some(unit.to_unit_data()),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::UnitUpdate.to_response())
        }
    }
}
