use crate::{
    core::constants::errors::AppError,
    features::{
        habits::{
            helpers::unit,
            structs::{
                models::unit::Unit, requests::unit::UnitCreateRequest,
                responses::unit::UnitResponse,
            },
        },
        profile::structs::models::User,
    },
};
use actix_web::{
    post,
    web::{Data, Json},
    HttpResponse, Responder,
};
use chrono::Utc;
use serde_json::json;
use sqlx::PgPool;
use uuid::Uuid;

#[post("/")]
pub async fn create_unit(
    pool: Data<PgPool>,
    body: Json<UnitCreateRequest>,
    request_user: User,
) -> impl Responder {
    if !request_user.is_admin {
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

    let unit = Unit {
        id: Uuid::new_v4(),
        short_name: json!(body.short_name).to_string(),
        long_name: json!(body.long_name).to_string(),
        created_at: Utc::now(),
    };

    let create_unit_result = unit::create_unit(&mut transaction, &unit).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match create_unit_result {
        Ok(_) => HttpResponse::Ok().json(UnitResponse {
            code: "UNIT_CREATED".to_string(),
            unit: Some(unit.to_unit_data()),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::UnitCreation.to_response())
        }
    }
}
