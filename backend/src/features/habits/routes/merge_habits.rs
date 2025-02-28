use crate::{
    core::constants::errors::AppError,
    features::{
        habits::{
            helpers::{
                habit::{self, get_habit_by_id},
                habit_category::get_habit_category_by_id,
                habit_daily_tracking, habit_participation,
            },
            structs::{
                requests::habit::{HabitUpdateRequest, MergeHabitsParams},
                responses::habit::HabitResponse,
            },
        },
        profile::structs::models::User,
    },
};
use actix_web::{
    post,
    web::{Data, Json, Path},
    HttpResponse, Responder,
};
use serde_json::json;
use sqlx::PgPool;

#[post("/merge/{habit_to_delete_id}/{habit_to_merge_on_id}")]
pub async fn merge_habits(
    pool: Data<PgPool>,
    params: Path<MergeHabitsParams>,
    body: Json<HabitUpdateRequest>,
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

    let habit_to_delete = match get_habit_by_id(&mut transaction, params.habit_to_delete_id).await {
        Ok(r) => match r {
            Some(habit) => habit,
            None => return HttpResponse::NotFound().json(AppError::HabitNotFound.to_response()),
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let mut habit_to_merge_on = match get_habit_by_id(&mut transaction, params.habit_to_merge_on_id)
        .await
    {
        Ok(r) => match r {
            Some(habit) => habit,
            None => return HttpResponse::NotFound().json(AppError::HabitNotFound.to_response()),
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    let category = match get_habit_category_by_id(&mut transaction, body.category_id).await {
        Ok(r) => match r {
            Some(category) => category,
            None => {
                return HttpResponse::NotFound().json(AppError::HabitCategoryNotFound.to_response())
            }
        },
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::DatabaseQuery.to_response());
        }
    };

    habit_to_merge_on.category_id = category.id;
    habit_to_merge_on.short_name = json!(body.short_name).to_string();
    habit_to_merge_on.long_name = json!(body.long_name).to_string();
    habit_to_merge_on.description = json!(body.description).to_string();
    habit_to_merge_on.reviewed = body.reviewed;
    habit_to_merge_on.icon = body.icon.clone();

    let update_habit_result = habit::update_habit(&mut transaction, &habit_to_merge_on).await;

    if let Err(e) = update_habit_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::HabitUpdate.to_response());
    }

    let replace_habit_daily_trackings_result = habit_daily_tracking::replace_daily_tracking_habit(
        &mut transaction,
        habit_to_delete.id,
        habit_to_merge_on.id,
    )
    .await;

    if let Err(e) = replace_habit_daily_trackings_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::HabitUpdate.to_response());
    }

    // We need to ensure unique constraint on 'habit_id / user_id' for habit_participations
    // So, we check that user participating in the old don't have a participation in the new one,
    // If they have, we should remove the old one, otherwise replace it.
    match habit_participation::get_habit_participations_for_habit(
        &mut transaction,
        habit_to_delete.id,
    )
    .await
    {
        Ok(habit_participations) => {
            for habit_participation_on_habit_to_delete in habit_participations {
                match habit_participation::get_habit_participation_for_user_and_habit(
                    &mut transaction,
                    habit_participation_on_habit_to_delete.user_id,
                    habit_to_merge_on.id,
                )
                .await
                {
                    Ok(habit_participation_on_habit_to_merge_on) => {
                        if habit_participation_on_habit_to_merge_on.is_none() {
                            let replace_habit_participations_result =
                                habit_participation::replace_participation_habit(
                                    &mut transaction,
                                    habit_to_delete.id,
                                    habit_to_merge_on.id,
                                )
                                .await;

                            if let Err(e) = replace_habit_participations_result {
                                eprintln!("Error: {}", e);
                                return HttpResponse::InternalServerError()
                                    .json(AppError::HabitUpdate.to_response());
                            }
                        } else {
                            let delete_habit_participation_result =
                                habit_participation::delete_habit_participation_by_id(
                                    &mut transaction,
                                    habit_participation_on_habit_to_delete.id,
                                )
                                .await;

                            if let Err(e) = delete_habit_participation_result {
                                eprintln!("Error: {}", e);
                                return HttpResponse::InternalServerError()
                                    .json(AppError::HabitUpdate.to_response());
                            }
                        }
                    }
                    Err(e) => {
                        eprintln!("Error: {}", e);
                        return HttpResponse::InternalServerError()
                            .json(AppError::HabitUpdate.to_response());
                    }
                }
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            return HttpResponse::InternalServerError().json(AppError::HabitUpdate.to_response());
        }
    }

    let delete_habit_result = habit::delete_habit_by_id(&mut transaction, habit_to_delete.id).await;

    if let Err(e) = delete_habit_result {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError().json(AppError::HabitUpdate.to_response());
    }

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    HttpResponse::Ok().json(HabitResponse {
        code: "HABIT_UPDATED".to_string(),
        habit: Some(habit_to_merge_on.to_habit_data()),
    })
}
