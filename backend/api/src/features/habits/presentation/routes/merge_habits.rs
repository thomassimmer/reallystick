use crate::{
    core::constants::errors::AppError,
    features::{
        auth::domain::entities::Claims,
        habits::{
            application::dto::{
                requests::habit::{HabitUpdateRequest, MergeHabitsParams},
                responses::habit::HabitResponse,
            },
            application::use_cases::merge_habits::MergeHabitsUseCase,
            infrastructure::repositories::{
                habit_category_repository::HabitCategoryRepositoryImpl,
                habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl,
                habit_participation_repository::HabitParticipationRepositoryImpl,
                habit_repository::HabitRepositoryImpl,
            },
        },
    },
};
use actix_web::{
    post,
    web::{Data, Json, Path, ReqData},
    HttpResponse, Responder,
};
use serde_json::json;
use sqlx::PgPool;
use tracing::error;

#[post("/merge/{habit_to_delete_id}/{habit_to_merge_on_id}")]
pub async fn merge_habits(
    pool: Data<PgPool>,
    params: Path<MergeHabitsParams>,
    body: Json<HabitUpdateRequest>,
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

    let pool_clone = pool.get_ref().clone();
    let habit_repo = HabitRepositoryImpl::new(pool_clone.clone());
    let habit_category_repo = HabitCategoryRepositoryImpl::new(pool_clone.clone());
    let daily_tracking_repo = HabitDailyTrackingRepositoryImpl::new(pool_clone.clone());
    let participation_repo = HabitParticipationRepositoryImpl::new(pool_clone.clone());

    let use_case = MergeHabitsUseCase::new(
        habit_repo,
        habit_category_repo,
        daily_tracking_repo,
        participation_repo,
    );

    let result = use_case
        .execute(
            params.habit_to_delete_id,
            params.habit_to_merge_on_id,
            json!(body.name),
            json!(body.description),
            body.category_id,
            body.reviewed,
            Some(body.icon.clone()),
            &mut transaction,
        )
        .await;

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match result {
        Ok(habit) => HttpResponse::Ok().json(HabitResponse {
            code: "HABIT_UPDATED".to_string(),
            habit: Some(habit.to_habit_data()),
        }),
        Err(e) => {
            error!("Error: {:?}", e);
            HttpResponse::InternalServerError().json(e.to_response())
        }
    }
}
