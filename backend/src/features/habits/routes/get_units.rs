use crate::{
    core::constants::errors::AppError,
    features::habits::{helpers::unit, structs::responses::unit::UnitsResponse},
};
use actix_web::{get, web::Data, HttpResponse, Responder};
use sqlx::PgPool;

#[get("/")]
pub async fn get_units(pool: Data<PgPool>) -> impl Responder {
    let get_units_result = unit::get_units(&**pool).await;

    match get_units_result {
        Ok(units) => HttpResponse::Ok().json(UnitsResponse {
            code: "UNITS_FETCHED".to_string(),
            units: units.iter().map(|h| h.to_unit_data()).collect(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
