use sqlx::{postgres::PgQueryResult, PgConnection};
use uuid::Uuid;

use crate::features::challenges::structs::models::challenge_daily_tracking::ChallengeDailyTracking;

pub async fn get_challenge_daily_tracking_by_id(
    conn: &mut PgConnection,
    challenge_daily_tracking_id: Uuid,
) -> Result<Option<ChallengeDailyTracking>, sqlx::Error> {
    sqlx::query_as!(
        ChallengeDailyTracking,
        r#"
        SELECT *
        from challenge_daily_trackings
        WHERE id = $1
        "#,
        challenge_daily_tracking_id,
    )
    .fetch_optional(conn)
    .await
}

pub async fn get_challenge_daily_trackings_for_challenge(
    conn: &mut PgConnection,
    challenge_id: Uuid,
) -> Result<Vec<ChallengeDailyTracking>, sqlx::Error> {
    sqlx::query_as!(
        ChallengeDailyTracking,
        r#"
        SELECT *
        FROM challenge_daily_trackings
        WHERE challenge_id = $1
        "#,
        challenge_id
    )
    .fetch_all(conn)
    .await
}

pub async fn get_challenge_daily_trackings_for_challenges(
    conn: &mut PgConnection,
    challenge_ids: Vec<Uuid>,
) -> Result<Vec<ChallengeDailyTracking>, sqlx::Error> {
    sqlx::query_as!(
        ChallengeDailyTracking,
        r#"
        SELECT *
        FROM challenge_daily_trackings
        WHERE challenge_id = ANY($1)
        "#,
        &challenge_ids
    )
    .fetch_all(conn)
    .await
}

pub async fn update_challenge_daily_tracking(
    conn: &mut PgConnection,
    challenge_daily_tracking: &ChallengeDailyTracking,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error> {
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
            weight_unit_id = $6
        WHERE id = $7
        "#,
        challenge_daily_tracking.day_of_program,
        challenge_daily_tracking.quantity_per_set,
        challenge_daily_tracking.quantity_of_set,
        challenge_daily_tracking.unit_id,
        challenge_daily_tracking.weight,
        challenge_daily_tracking.weight_unit_id,
        challenge_daily_tracking.id
    )
    .execute(conn)
    .await
}

pub async fn create_challenge_daily_tracking(
    conn: &mut PgConnection,
    challenge_daily_tracking: &ChallengeDailyTracking,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        ChallengeDailyTracking,
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
            weight_unit_id
        )
        VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10 )
        "#,
        challenge_daily_tracking.id,
        challenge_daily_tracking.habit_id,
        challenge_daily_tracking.challenge_id,
        challenge_daily_tracking.day_of_program,
        challenge_daily_tracking.created_at,
        challenge_daily_tracking.quantity_per_set,
        challenge_daily_tracking.quantity_of_set,
        challenge_daily_tracking.unit_id,
        challenge_daily_tracking.weight,
        challenge_daily_tracking.weight_unit_id
    )
    .execute(conn)
    .await
}

pub async fn delete_challenge_daily_tracking_by_id(
    conn: &mut PgConnection,
    challenge_daily_tracking_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        ChallengeDailyTracking,
        r#"
        DELETE
        from challenge_daily_trackings
        WHERE id = $1
        "#,
        challenge_daily_tracking_id,
    )
    .execute(conn)
    .await
}

pub async fn replace_daily_tracking_challenge(
    conn: &mut PgConnection,
    old_habit_id: Uuid,
    new_habit_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error> {
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
    .execute(conn)
    .await
}
