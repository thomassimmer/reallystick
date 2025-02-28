use crate::{
    core::constants::errors::AppError,
    features::profile::{
        helpers::user::delete_user_by_id,
        structs::{models::User, responses::DeleteAccountResponse},
    },
};
use actix_web::{delete, web::Data, HttpResponse, Responder};
use sqlx::PgPool;

#[delete("/me")]
pub async fn delete_account(pool: Data<PgPool>, request_user: User) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let delete_result = delete_user_by_id(&mut transaction, request_user.id).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match delete_result {
        Ok(_) => HttpResponse::Ok().json(DeleteAccountResponse {
            code: "ACCOUNT_DELETED".to_string(),
        }),
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::UserUpdate.to_response())
        }
    }
}
