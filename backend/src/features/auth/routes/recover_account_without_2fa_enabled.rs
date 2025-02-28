use crate::{
    core::constants::errors::AppError,
    features::{
        auth::{
            helpers::{
                recovery_code::{delete_recovery_code_for_user, get_recovery_code_for_user},
                token::{delete_user_tokens, generate_tokens},
            },
            structs::{
                requests::RecoverAccountWithout2FAEnabledRequest, responses::UserLoginResponse,
            },
        },
        profile::helpers::{device_info::get_user_agent, profile::get_user_by_username},
    },
};
use actix_web::{post, web, HttpRequest, HttpResponse, Responder};
use argon2::{Argon2, PasswordHash, PasswordVerifier};
use sqlx::PgPool;

#[post("/recover")]
pub async fn recover_account_without_2fa_enabled(
    req: HttpRequest,
    body: web::Json<RecoverAccountWithout2FAEnabledRequest>,
    pool: web::Data<PgPool>,
    secret: web::Data<String>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let body = body.into_inner();
    let username_lower = body.username.to_lowercase();

    // Check if user already exists
    let existing_user = get_user_by_username(&mut transaction, username_lower.clone()).await;

    let mut user = match existing_user {
        Ok(existing_user) => {
            if let Some(user) = existing_user {
                user
            } else {
                return HttpResponse::Unauthorized()
                    .json(AppError::InvalidUsernameOrRecoveryCode.to_response());
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let recovery_code = match get_recovery_code_for_user(user.id, &mut transaction).await {
        Ok(r) => match r {
            Some(r) => r,
            None => {
                return HttpResponse::Unauthorized()
                    .json(AppError::InvalidUsernameOrRecoveryCode.to_response())
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseTransaction.to_response());
        }
    };

    let parsed_hash = if let Ok(parsed_hash) = PasswordHash::new(&recovery_code.recovery_code) {
        parsed_hash
    } else {
        return HttpResponse::InternalServerError().json(AppError::PasswordHash.to_response());
    };

    let argon2 = Argon2::default();

    let is_valid = argon2
        .verify_password(body.recovery_code.as_bytes(), &parsed_hash)
        .is_ok();

    if is_valid {
        let delete_recovery_code_result =
            delete_recovery_code_for_user(user.id, &mut transaction).await;

        if delete_recovery_code_result.is_err() {
            return HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response());
        }
    } else {
        return HttpResponse::Unauthorized()
            .json(AppError::InvalidUsernameOrRecoveryCode.to_response());
    }

    let delete_result = delete_user_tokens(user.id, &mut transaction).await;

    if let Err(e) = delete_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::UserTokenDeletion.to_response());
    }

    let parsed_device_info = get_user_agent(req).await;

    let (access_token, refresh_token) = match generate_tokens(
        secret.as_bytes(),
        user.id,
        user.is_admin,
        user.username,
        parsed_device_info,
        &mut transaction,
    )
    .await
    {
        Ok((access_token, refresh_token)) => (access_token, refresh_token),
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::TokenGeneration.to_response());
        }
    };

    user.password_is_expired = true;

    let updated_user_result = sqlx::query_scalar!(
        r#"
        UPDATE users
        SET password_is_expired = $1
        WHERE id = $2
        "#,
        user.password_is_expired,
        user.id
    )
    .fetch_optional(&mut *transaction)
    .await;

    if let Err(e) = updated_user_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response());
    }

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(UserLoginResponse {
        code: "USER_LOGGED_IN_AFTER_ACCOUNT_RECOVERY".to_string(),
        access_token,
        refresh_token,
        public_key: user.public_key,
        private_key_encrypted: Some(recovery_code.private_key_encrypted),
        salt_used_to_derive_key: Some(recovery_code.salt_used_to_derive_key_from_recovery_code),
    })
}
