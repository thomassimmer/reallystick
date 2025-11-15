// Merge habits use case

use crate::core::constants::errors::AppError;
use crate::features::habits::domain::entities::habit::{Habit, HABIT_DESCRIPTION_MAX_LENGTH};
use crate::features::habits::infrastructure::repositories::habit_category_repository::HabitCategoryRepositoryImpl;
use crate::features::habits::infrastructure::repositories::habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl;
use crate::features::habits::infrastructure::repositories::habit_participation_repository::HabitParticipationRepositoryImpl;
use crate::features::habits::infrastructure::repositories::habit_repository::HabitRepositoryImpl;
use serde_json::json;
use sqlx::Postgres;
use uuid::Uuid;

pub struct MergeHabitsUseCase {
    habit_repo: HabitRepositoryImpl,
    habit_category_repo: HabitCategoryRepositoryImpl,
    _daily_tracking_repo: HabitDailyTrackingRepositoryImpl,
    participation_repo: HabitParticipationRepositoryImpl,
}

impl MergeHabitsUseCase {
    pub fn new(
        habit_repo: HabitRepositoryImpl,
        habit_category_repo: HabitCategoryRepositoryImpl,
        daily_tracking_repo: HabitDailyTrackingRepositoryImpl,
        participation_repo: HabitParticipationRepositoryImpl,
    ) -> Self {
        Self {
            habit_repo,
            habit_category_repo,
            _daily_tracking_repo: daily_tracking_repo,
            participation_repo,
        }
    }

    #[allow(clippy::too_many_arguments)]
    pub async fn execute(
        &self,
        habit_to_delete_id: Uuid,
        habit_to_merge_on_id: Uuid,
        name: serde_json::Value,
        description: serde_json::Value,
        category_id: Uuid,
        reviewed: bool,
        icon: Option<String>,
        transaction: &mut sqlx::Transaction<'_, Postgres>,
    ) -> Result<Habit, AppError> {
        // Validate description length
        if let Some(desc_map) = description.as_object() {
            for (_language_code, desc_value) in desc_map {
                if let Some(desc_str) = desc_value.as_str() {
                    if desc_str.len() > HABIT_DESCRIPTION_MAX_LENGTH {
                        return Err(AppError::HabitDescriptionTooLong);
                    }
                }
            }
        }

        // Get habits
        let _habit_to_delete = self
            .habit_repo
            .get_by_id_with_executor(habit_to_delete_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::HabitNotFound)?;

        let mut habit_to_merge_on = self
            .habit_repo
            .get_by_id_with_executor(habit_to_merge_on_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::HabitNotFound)?;

        // Get category
        let category = self
            .habit_category_repo
            .get_by_id_with_executor(category_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?
            .ok_or(AppError::HabitCategoryNotFound)?;

        // Update habit to merge on
        habit_to_merge_on.category_id = category.id;
        habit_to_merge_on.name = json!(name).to_string();
        habit_to_merge_on.description = json!(description).to_string();
        habit_to_merge_on.reviewed = reviewed;
        habit_to_merge_on.icon = icon.unwrap_or_default();

        self.habit_repo
            .update_with_executor(&habit_to_merge_on, &mut **transaction)
            .await
            .map_err(|_| AppError::HabitUpdate)?;

        // Replace daily trackings
        sqlx::query!(
            r#"
            UPDATE habit_daily_trackings
            SET habit_id = $2
            WHERE habit_id = $1
            "#,
            habit_to_delete_id,
            habit_to_merge_on_id,
        )
        .execute(&mut **transaction)
        .await
        .map_err(|_| AppError::HabitUpdate)?;

        // Handle participations - get all participations for habit to delete
        let participations_to_delete = self
            .participation_repo
            .get_by_habit_id_with_executor(habit_to_delete_id, &mut **transaction)
            .await
            .map_err(|_| AppError::DatabaseQuery)?;

        for participation in participations_to_delete {
            // Check if user already has participation in habit to merge on
            let existing_participation = self
                .participation_repo
                .get_by_user_and_habit_id_with_executor(
                    participation.user_id,
                    habit_to_merge_on_id,
                    &mut **transaction,
                )
                .await
                .map_err(|_| AppError::DatabaseQuery)?;

            if existing_participation.is_none() {
                // Replace participation habit_id
                sqlx::query!(
                    r#"
                    UPDATE habit_participations
                    SET habit_id = $2
                    WHERE habit_id = $1 AND user_id = $3
                    "#,
                    habit_to_delete_id,
                    habit_to_merge_on_id,
                    participation.user_id,
                )
                .execute(&mut **transaction)
                .await
                .map_err(|_| AppError::HabitUpdate)?;
            } else {
                // Delete the old participation
                self.participation_repo
                    .delete_with_executor(participation.id, &mut **transaction)
                    .await
                    .map_err(|_| AppError::HabitUpdate)?;
            }
        }

        // Delete habit to delete
        self.habit_repo
            .delete_with_executor(habit_to_delete_id, &mut **transaction)
            .await
            .map_err(|_| AppError::HabitUpdate)?;

        Ok(habit_to_merge_on)
    }
}
