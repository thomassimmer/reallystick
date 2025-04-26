use sqlx::{postgres::PgQueryResult, Executor, Postgres};
use uuid::Uuid;

use crate::features::challenges::structs::models::challenge_daily_tracking::ChallengeDailyTracking;

pub async fn get_challenge_daily_tracking_by_id<'a, E>(
    executor: E,
    challenge_daily_tracking_id: Uuid,
) -> Result<Option<ChallengeDailyTracking>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeDailyTracking,
        r#"
        SELECT *
        from challenge_daily_trackings
        WHERE id = $1
        "#,
        challenge_daily_tracking_id,
    )
    .fetch_optional(executor)
    .await
}

pub async fn get_challenge_daily_trackings_for_challenge<'a, E>(
    executor: E,
    challenge_id: Uuid,
) -> Result<Vec<ChallengeDailyTracking>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeDailyTracking,
        r#"
        SELECT *
        FROM challenge_daily_trackings
        WHERE challenge_id = $1
        "#,
        challenge_id
    )
    .fetch_all(executor)
    .await
}

pub async fn get_challenge_daily_trackings_for_challenges<'a, E>(
    executor: E,
    challenge_ids: Vec<Uuid>,
) -> Result<Vec<ChallengeDailyTracking>, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeDailyTracking,
        r#"
        SELECT *
        FROM challenge_daily_trackings
        WHERE challenge_id = ANY($1)
        "#,
        &challenge_ids
    )
    .fetch_all(executor)
    .await
}

pub async fn update_challenge_daily_tracking<'a, E>(
    executor: E,
    challenge_daily_tracking: &ChallengeDailyTracking,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeDailyTracking,
        r#"
        UPDATE challenge_daily_trackings
        SET
            day_of_program = $1,
            quantity_per_set = $2,
            quantity_of_set = $3,
            unit_id = $4,
            weight = $5,
            weight_unit_id = $6,
            note = $7
        WHERE id = $8
        "#,
        challenge_daily_tracking.day_of_program,
        challenge_daily_tracking.quantity_per_set,
        challenge_daily_tracking.quantity_of_set,
        challenge_daily_tracking.unit_id,
        challenge_daily_tracking.weight,
        challenge_daily_tracking.weight_unit_id,
        challenge_daily_tracking.note,
        challenge_daily_tracking.id
    )
    .execute(executor)
    .await
}

pub async fn create_challenge_daily_trackings<'a, E>(
    executor: E,
    challenge_daily_trackings: &[ChallengeDailyTracking],
) -> Result<(), sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    if challenge_daily_trackings.is_empty() {
        return Ok(()); // No data to insert, return early
    }

    let mut ids = Vec::with_capacity(challenge_daily_trackings.len());
    let mut habit_ids = Vec::with_capacity(challenge_daily_trackings.len());
    let mut challenge_ids = Vec::with_capacity(challenge_daily_trackings.len());
    let mut days_of_program = Vec::with_capacity(challenge_daily_trackings.len());
    let mut created_ats = Vec::with_capacity(challenge_daily_trackings.len());
    let mut quantity_per_sets = Vec::with_capacity(challenge_daily_trackings.len());
    let mut quantity_of_sets = Vec::with_capacity(challenge_daily_trackings.len());
    let mut unit_ids = Vec::with_capacity(challenge_daily_trackings.len());
    let mut weights = Vec::with_capacity(challenge_daily_trackings.len());
    let mut weight_unit_ids = Vec::with_capacity(challenge_daily_trackings.len());
    let mut notes = Vec::with_capacity(challenge_daily_trackings.len());

    for tracking in challenge_daily_trackings {
        ids.push(tracking.id);
        habit_ids.push(tracking.habit_id);
        challenge_ids.push(tracking.challenge_id);
        days_of_program.push(tracking.day_of_program);
        created_ats.push(tracking.created_at);
        quantity_per_sets.push(tracking.quantity_per_set);
        quantity_of_sets.push(tracking.quantity_of_set);
        unit_ids.push(tracking.unit_id);
        weights.push(tracking.weight as f64);
        weight_unit_ids.push(tracking.weight_unit_id);
        notes.push(tracking.note.clone());
    }

    sqlx::query!(
        r#"
        INSERT INTO challenge_daily_trackings (
            id,
            habit_id,
            challenge_id,
            day_of_program,
            created_at,
            quantity_per_set,
            quantity_of_set,
            unit_id,
            weight,
            weight_unit_id,
            note
        )
        SELECT * FROM UNNEST(
            $1::UUID[],
            $2::UUID[],
            $3::UUID[],
            $4::INT[],
            $5::TIMESTAMPTZ[],
            $6::DOUBLE PRECISION[],
            $7::INT[],
            $8::UUID[],
            $9::FLOAT8[],
            $10::UUID[],
            $11::TEXT[]
        )
        "#,
        &ids,
        &habit_ids,
        &challenge_ids,
        &days_of_program,
        &created_ats,
        &quantity_per_sets,
        &quantity_of_sets,
        &unit_ids,
        &weights,
        &weight_unit_ids,
        &notes as &[Option<String>]
    )
    .execute(executor)
    .await?;

    Ok(())
}

pub async fn delete_challenge_daily_tracking_by_id<'a, E>(
    executor: E,
    challenge_daily_tracking_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeDailyTracking,
        r#"
        DELETE
        from challenge_daily_trackings
        WHERE id = $1
        "#,
        challenge_daily_tracking_id,
    )
    .execute(executor)
    .await
}

pub async fn replace_daily_tracking_challenge<'a, E>(
    executor: E,
    old_habit_id: Uuid,
    new_habit_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    sqlx::query_as!(
        ChallengeDailyTracking,
        r#"
        UPDATE challenge_daily_trackings
        SET habit_id = $2
        WHERE habit_id = $1
        "#,
        old_habit_id,
        new_habit_id,
    )
    .execute(executor)
    .await
}

pub async fn get_challenge_daily_tracking_count<'a, E>(executor: E) -> Result<i64, sqlx::Error>
where
    E: Executor<'a, Database = Postgres>,
{
    let row = sqlx::query!(
        r#"
        SELECT COUNT(*) as count
        FROM challenge_daily_trackings
        "#,
    )
    .fetch_one(executor)
    .await?;

    Ok(row.count.unwrap_or(0))
}
