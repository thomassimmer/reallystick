// Get devices route - uses clean architecture

use crate::core::constants::errors::AppError;
use crate::features::auth::application::use_cases::get_devices::GetDevicesUseCase;
use crate::features::auth::domain::entities::Claims;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::auth::structs::models::TokenCache;
use crate::features::profile::application::dto::responses::{DeviceData, DevicesResponse};
use crate::features::profile::domain::entities::ParsedDeviceInfo;
use actix_web::web::{Data, ReqData};
use actix_web::{get, HttpResponse, Responder};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_devices(
    claims: ReqData<Claims>,
    pool: Data<PgPool>,
    cached_tokens: Data<TokenCache>,
) -> impl Responder {
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
    let token_repo = UserTokenRepositoryImpl::new(pool_clone);
    let get_devices_use_case = GetDevicesUseCase::new(token_repo);

    // Execute use case
    let tokens = match get_devices_use_case
        .execute(claims.user_id, &mut transaction)
        .await
    {
        Ok(tokens) => tokens,
        Err(e) => {
            error!("Error: {}", e);
            if let Err(e) = transaction.rollback().await {
                error!("Error rolling back: {}", e);
            }
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    // Build device data with cache
    let mut devices = Vec::new();
    for token in tokens {
        devices.push(DeviceData {
            token_id: token.token_id,
            parsed_device_info: ParsedDeviceInfo {
                os: token.os,
                is_mobile: token.is_mobile,
                browser: token.browser,
                app_version: token.app_version,
                model: token.model,
            },
            last_activity_date: cached_tokens.get_value_for_key(token.token_id).await,
        });
    }

    HttpResponse::Ok().json(DevicesResponse {
        code: "DEVICES_FETCHED".to_string(),
        devices,
    })
}
