use chrono::Days;

use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::PgPool;
use tracing::{error, info};

use crate::core::structs::redis_messages::UserRemovedEvent;
use crate::features::challenges::infrastructure::repositories::{
    challenge_daily_tracking_repository::ChallengeDailyTrackingRepositoryImpl,
    challenge_participation_repository::ChallengeParticipationRepositoryImpl,
    challenge_repository::ChallengeRepositoryImpl,
};
use crate::features::habits::infrastructure::repositories::{
    habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl,
    habit_participation_repository::HabitParticipationRepositoryImpl,
};
use crate::features::private_discussions::infrastructure::repositories::private_message_repository::PrivateMessageRepositoryImpl;
use crate::features::profile::domain::entities::User;
use crate::features::profile::domain::repositories::UserRepository;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;
use crate::features::public_discussions::infrastructure::repositories::{
    public_message_like_repository::PublicMessageLikeRepositoryImpl,
    public_message_report_repository::PublicMessageReportRepositoryImpl,
    public_message_repository::PublicMessageRepositoryImpl,
};

use super::mock_now::now;

pub async fn remove_users_marked_as_deleted(
    pool: &PgPool,
    redis_client: &Client,
) -> Result<(), sqlx::Error> {
    let user_repo = UserRepositoryImpl::new(pool.clone());
    let users = user_repo
        .get_not_deleted_but_marked_as_deleted()
        .await
        .map_err(|e| sqlx::Error::Configuration(Box::new(std::io::Error::other(e))))?;

    for user in users.clone() {
        delete_user_data(pool, user, redis_client).await?;
    }

    info!("Successfully deleted {} users.", users.len());

    Ok(())
}

pub async fn delete_user_data(
    pool: &PgPool,
    user: User,
    redis_client: &Client,
) -> Result<(), sqlx::Error> {
    if let Some(deleted_at) = user.deleted_at {
        if let Some(date_after_which_user_can_be_deleted) =
            deleted_at.checked_add_days(Days::new(0))
        {
            if now() > date_after_which_user_can_be_deleted {
                let mut transaction = match pool.begin().await {
                    Ok(t) => t,
                    Err(_) => panic!("Can't get a transaction."),
                };

                let public_message_repo = PublicMessageRepositoryImpl::new(pool.clone());
                if let Err(e) = public_message_repo
                    .mark_as_deleted_for_user_with_executor(user.id, &mut *transaction)
                    .await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                let habit_daily_tracking_repo = HabitDailyTrackingRepositoryImpl::new(pool.clone());
                if let Err(e) = habit_daily_tracking_repo
                    .delete_by_user_id_with_executor(user.id, &mut *transaction)
                    .await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                let challenge_repo = ChallengeRepositoryImpl::new(pool.clone());
                let daily_tracking_repo = ChallengeDailyTrackingRepositoryImpl::new(pool.clone());
                let participation_repo = ChallengeParticipationRepositoryImpl::new(pool.clone());

                match challenge_repo
                    .get_created_with_executor(user.id, &mut *transaction)
                    .await
                {
                    Ok(challenges) => {
                        for challenge in challenges {
                            if let Err(e) = daily_tracking_repo
                                .delete_by_challenge_id_with_executor(
                                    challenge.id,
                                    &mut *transaction,
                                )
                                .await
                            {
                                error!("Error: {}", e);
                            }
                        }
                    }
                    Err(e) => {
                        error!("Error: {}", e);
                    }
                };

                if let Err(e) = challenge_repo
                    .mark_as_deleted_for_user_with_executor(user.id, &mut *transaction)
                    .await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                if let Err(e) = participation_repo
                    .delete_by_user_id_with_executor(user.id, &mut *transaction)
                    .await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                let habit_participation_repo = HabitParticipationRepositoryImpl::new(pool.clone());
                if let Err(e) = habit_participation_repo
                    .delete_by_user_id_with_executor(user.id, &mut *transaction)
                    .await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                let private_message_repo = PrivateMessageRepositoryImpl::new(pool.clone());
                if let Err(e) = private_message_repo
                    .delete_by_user_id_with_executor(user.id, &mut *transaction)
                    .await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                let user_repo = UserRepositoryImpl::new(pool.clone());
                if let Err(e) = user_repo
                    .mark_as_deleted_with_executor(user.id, &mut *transaction)
                    .await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                let public_message_like_repo = PublicMessageLikeRepositoryImpl::new(pool.clone());
                if let Err(e) = public_message_like_repo
                    .delete_by_user_id_with_executor(user.id, &mut *transaction)
                    .await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                let public_message_report_repo =
                    PublicMessageReportRepositoryImpl::new(pool.clone());
                if let Err(e) = public_message_report_repo
                    .delete_by_user_id_with_executor(user.id, &mut *transaction)
                    .await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                transaction.commit().await?;

                match redis_client.get_multiplexed_async_connection().await {
                    Ok(mut con) => {
                        let result: Result<(), redis::RedisError> = con
                            .publish(
                                "user_deleted",
                                json!(UserRemovedEvent { user_id: user.id }).to_string(),
                            )
                            .await;
                        if let Err(e) = result {
                            error!("Error: {}", e);
                        }
                    }
                    Err(e) => {
                        error!("Error: {}", e);
                    }
                }

                info!("Successfully deleted data for user: {}", user.username);
            }
        }
    }

    Ok(())
}
