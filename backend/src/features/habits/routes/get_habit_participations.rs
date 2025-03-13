use crate::{
    core::constants::errors::AppError,
    features::{
        auth::structs::models::Claims,
        habits::{
            helpers::habit_participation,
            structs::responses::habit_participation::HabitParticipationsResponse,
        },
    },
};
use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_habit_participations(
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
) -> impl Responder {
    let get_habits_result =
        habit_participation::get_habit_participations_for_user(&**pool, request_claims.user_id)
            .await;

    match get_habits_result {
        Ok(habit_participations) => HttpResponse::Ok().json(HabitParticipationsResponse {
            code: "HABIT_PARTICIPATIONS_FETCHED".to_string(),
            habit_participations: habit_participations
                .iter()
                .map(|hp| hp.to_habit_participation_data())
                .collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response())
        }
    }
}
