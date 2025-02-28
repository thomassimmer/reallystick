use crate::{
    core::constants::errors::AppError,
    features::habits::{
        helpers::habit_participation::delete_habit_participation_by_id,
        structs::{
            requests::habit_participation::GetHabitParticipationParams,
            responses::habit_participation::HabitParticipationResponse,
        },
    },
};
use actix_web::{
    delete,
    web::{Data, Path},
    HttpResponse, Responder,
};
use sqlx::PgPool;

#[delete("/{habit_participation_id}")]
pub async fn delete_habit_participation(
    pool: Data<PgPool>,
    params: Path<GetHabitParticipationParams>,
) -> impl Responder {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    let delete_habit_participation_result =
        delete_habit_participation_by_id(&mut *transaction, params.habit_participation_id).await;

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match delete_habit_participation_result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                HttpResponse::Ok().json(HabitParticipationResponse {
                    code: "HABIT_PARTICIPATION_DELETED".to_string(),
                    habit_participation: None,
                })
            } else {
                HttpResponse::NotFound().json(AppError::HabitParticipationNotFound.to_response())
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            HttpResponse::InternalServerError()
                .json(AppError::HabitParticipationDelete.to_response())
        }
    }
}
