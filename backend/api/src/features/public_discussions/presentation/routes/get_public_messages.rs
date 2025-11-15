use crate::{
    core::constants::errors::AppError,
    features::{
        challenges::infrastructure::repositories::challenge_repository::ChallengeRepositoryImpl,
        habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl,
        public_discussions::{
            application::dto::{
                requests::public_message::GetPublicMessagesParams,
                responses::public_message::PublicMessagesResponse,
            },
            infrastructure::repositories::public_message_repository::PublicMessageRepositoryImpl,
        },
    },
};
use actix_web::{
    get,
    web::{Data, Query},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

#[get("/")]
pub async fn get_public_messages(
    pool: Data<PgPool>,
    query: Query<GetPublicMessagesParams>,
) -> impl Responder {
    let params = query.into_inner();

    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(e) => {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        }
    };

    // Check if a habit or a challenge is given
    if params.habit_id.is_none() && params.challenge_id.is_none() {
        return HttpResponse::BadRequest().json(AppError::NoHabitNorChallengePassed.to_response());
    }

    // Check if a habit and a challenge were given
    if params.habit_id.is_some() && params.challenge_id.is_some() {
        return HttpResponse::BadRequest()
            .json(AppError::BothHabitAndChallengePassed.to_response());
    }

    // Create repositories
    let pool_clone = pool.get_ref().clone();
    let message_repo = PublicMessageRepositoryImpl::new(pool_clone.clone());
    let habit_repo = HabitRepositoryImpl::new(pool_clone.clone());
    let challenge_repo = ChallengeRepositoryImpl::new(pool_clone.clone());

    // Check if habit exists
    if let Some(habit_id) = params.habit_id {
        match habit_repo
            .get_by_id_with_executor(habit_id, &mut *transaction)
            .await
        {
            Ok(Some(_)) => {}
            Ok(None) => {
                if let Err(e) = transaction.rollback().await {
                    error!("Error rolling back: {}", e);
                }
                return HttpResponse::NotFound().json(AppError::HabitNotFound.to_response());
            }
            Err(e) => {
                error!("Error: {}", e);
                if let Err(e) = transaction.rollback().await {
                    error!("Error rolling back: {}", e);
                }
                return HttpResponse::InternalServerError()
                    .json(AppError::DatabaseQuery.to_response());
            }
        }
    }

    // Check if challenge exists
    if let Some(challenge_id) = params.challenge_id {
        match challenge_repo
            .get_by_id_with_executor(challenge_id, &mut *transaction)
            .await
        {
            Ok(Some(_)) => {}
            Ok(None) => {
                if let Err(e) = transaction.rollback().await {
                    error!("Error rolling back: {}", e);
                }
                return HttpResponse::NotFound().json(AppError::ChallengeNotFound.to_response());
            }
            Err(e) => {
                error!("Error: {}", e);
                if let Err(e) = transaction.rollback().await {
                    error!("Error rolling back: {}", e);
                }
                return HttpResponse::InternalServerError()
                    .json(AppError::DatabaseQuery.to_response());
            }
        }
    }

    // Get messages
    let get_messages_result = if let Some(challenge_id) = params.challenge_id {
        message_repo
            .get_by_challenge_id_with_executor(challenge_id, &mut *transaction)
            .await
    } else if let Some(habit_id) = params.habit_id {
        message_repo
            .get_by_habit_id_with_executor(habit_id, &mut *transaction)
            .await
    } else {
        Ok(vec![])
    };

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
        return HttpResponse::InternalServerError()
            .json(AppError::DatabaseTransaction.to_response());
    }

    match get_messages_result {
        Ok(messages) => HttpResponse::Ok().json(PublicMessagesResponse {
            code: "PUBLIC_MESSAGE_FETCHED".to_string(),
            messages: messages
                .iter()
                .map(|m| m.to_public_message_data())
                .collect(),
        }),
        Err(e) => {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::PublicMessageCreation.to_response())
        }
    }
}
