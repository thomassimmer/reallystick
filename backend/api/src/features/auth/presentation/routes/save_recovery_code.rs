use actix_web::{
    post,
    web::{self, Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

use crate::{
    core::constants::errors::AppError,
    features::auth::{
        application::{
            dto::{requests::SaveRecoveryCodeRequest, responses::SaveRecoveryCodeResponse},
            use_cases::save_recovery_code::SaveRecoveryCodeUseCase,
        },
        domain::entities::Claims,
        infrastructure::repositories::recovery_code_repository::RecoveryCodeRepositoryImpl,
    },
};

#[post("/save-recovery-code")]
pub async fn save_recovery_code(
    body: web::Json<SaveRecoveryCodeRequest>,
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
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
    let recovery_code_repo = RecoveryCodeRepositoryImpl::new(pool_clone);
    let save_recovery_code_use_case = SaveRecoveryCodeUseCase::new(recovery_code_repo);

    // Execute use case
    let result = save_recovery_code_use_case
        .execute(
            request_claims.user_id,
            body.recovery_code.clone(),
            body.private_key_encrypted.clone(),
            body.salt_used_to_derive_key_from_recovery_code.clone(),
            &mut transaction,
        )
        .await;

    if let Err(e) = result {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::RecoveryCodeCreation.to_response());
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Created().json(SaveRecoveryCodeResponse {
        code: "NEW_RECOVERY_CODE_SAVED".to_string(),
    })
}
