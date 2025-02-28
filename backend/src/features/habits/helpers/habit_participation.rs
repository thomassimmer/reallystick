use sqlx::{postgres::PgQueryResult, PgConnection};
use uuid::Uuid;

use crate::features::habits::structs::models::habit_participation::HabitParticipation;

pub async fn get_habit_participation_by_id(
    conn: &mut PgConnection,
    habit_participation_id: Uuid,
) -> Result<Option<HabitParticipation>, sqlx::Error> {
    sqlx::query_as!(
        HabitParticipation,
        r#"
        SELECT *
        from habit_participations
        WHERE id = $1
        "#,
        habit_participation_id,
    )
    .fetch_optional(conn)
    .await
}

pub async fn get_habit_participations_for_user(
    conn: &mut PgConnection,
    user_id: Uuid,
) -> Result<Vec<HabitParticipation>, sqlx::Error> {
    sqlx::query_as!(
        HabitParticipation,
        r#"
        SELECT *
        from habit_participations
        WHERE user_id = $1
        "#,
        user_id
    )
    .fetch_all(conn)
    .await
}

pub async fn get_habit_participations_for_user_and_habit(
    conn: &mut PgConnection,
    user_id: Uuid,
    habit_id: Uuid,
) -> Result<Vec<HabitParticipation>, sqlx::Error> {
    sqlx::query_as!(
        HabitParticipation,
        r#"
        SELECT *
        from habit_participations
        WHERE user_id = $1 AND habit_id = $2
        "#,
        user_id,
        habit_id
    )
    .fetch_all(conn)
    .await
}

pub async fn update_habit_participation(
    conn: &mut PgConnection,
    habit_participation: &HabitParticipation,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        HabitParticipation,
        r#"
        UPDATE habit_participations
        SET color = $1, to_gain = $2
        WHERE id = $3
        "#,
        habit_participation.color,
        habit_participation.to_gain,
        habit_participation.id
    )
    .execute(conn)
    .await
}

pub async fn create_habit_participation(
    conn: &mut PgConnection,
    habit_participation: &HabitParticipation,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        HabitParticipation,
        r#"
        INSERT INTO habit_participations (
            id,
            user_id,
            habit_id,
            color,
            to_gain,
            created_at
        )
        VALUES ( $1, $2, $3, $4, $5, $6 )
        "#,
        habit_participation.id,
        habit_participation.user_id,
        habit_participation.habit_id,
        habit_participation.color,
        habit_participation.to_gain,
        habit_participation.created_at,
    )
    .execute(conn)
    .await
}

pub async fn delete_habit_participation_by_id(
    conn: &mut PgConnection,
    habit_participation_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        Habit,
        r#"
        DELETE
        from habit_participations
        WHERE id = $1
        "#,
        habit_participation_id,
    )
    .execute(conn)
    .await
}

pub async fn replace_participation_habit(
    conn: &mut PgConnection,
    old_habit_id: Uuid,
    new_habit_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        HabitParticipation,
        r#"
        UPDATE habit_participations
        SET habit_id = $2
        WHERE habit_id = $1
        "#,
        old_habit_id,
        new_habit_id,
    )
    .execute(conn)
    .await
}
