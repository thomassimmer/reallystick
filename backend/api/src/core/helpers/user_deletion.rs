use chrono::Days;

use redis::{AsyncCommands, Client};
use serde_json::json;
use sqlx::PgPool;
use tracing::{error, info};

use crate::core::structs::redis_messages::UserRemovedEvent;
use crate::features::challenges::helpers::challenge::{
    get_created_challenges, mark_challenges_as_deleted_for_user,
};
use crate::features::challenges::helpers::challenge_daily_tracking::delete_all_daily_trackings_for_challenge;
use crate::features::challenges::helpers::challenge_participation::delete_challenge_participations_for_user;
use crate::features::habits::helpers::habit_daily_tracking::delete_habit_daily_tracking_for_user;
use crate::features::habits::helpers::habit_participation::delete_habit_participations_for_user;
use crate::features::private_discussions::helpers::private_message::delete_private_messages_for_user;
use crate::features::profile::helpers::profile::{
    get_not_deleted_but_marked_as_deleted_users, mark_user_as_deleted,
};
use crate::features::profile::structs::models::User;
use crate::features::public_discussions::helpers::public_message::mark_public_messages_as_deleted_for_user;
use crate::features::public_discussions::helpers::public_message_like::delete_public_message_likes_for_user;
use crate::features::public_discussions::helpers::public_message_report::delete_public_message_reports_for_user;

use super::mock_now::now;

pub async fn remove_users_marked_as_deleted(
    pool: &PgPool,
    redis_client: &Client,
) -> Result<(), sqlx::Error> {
    let users = get_not_deleted_but_marked_as_deleted_users(pool).await?;

    for user in users.clone() {
        delete_user_data(&pool, user, &redis_client).await?;
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

                if let Err(e) =
                    mark_public_messages_as_deleted_for_user(&mut *transaction, user.id).await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                if let Err(e) =
                    delete_habit_daily_tracking_for_user(&mut *transaction, user.id).await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                match get_created_challenges(&mut *transaction, user.id).await {
                    Ok(challenges) => {
                        for challenge in challenges {
                            if let Err(e) = delete_all_daily_trackings_for_challenge(
                                &mut *transaction,
                                challenge.id,
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

                if let Err(e) =
                    mark_challenges_as_deleted_for_user(&mut *transaction, user.id).await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                if let Err(e) =
                    delete_challenge_participations_for_user(&mut *transaction, user.id).await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                if let Err(e) =
                    delete_habit_participations_for_user(&mut *transaction, user.id).await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                if let Err(e) = delete_private_messages_for_user(&mut *transaction, user.id).await {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                if let Err(e) = mark_user_as_deleted(&mut *transaction, user.id).await {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                if let Err(e) =
                    delete_public_message_likes_for_user(&mut *transaction, user.id).await
                {
                    error!("Error: {}", e);
                    transaction.rollback().await?;
                    return Ok(());
                }

                if let Err(e) =
                    delete_public_message_reports_for_user(&mut *transaction, user.id).await
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
