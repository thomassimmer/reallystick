use sqlx::{postgres::PgQueryResult, PgConnection};
use uuid::Uuid;

use crate::features::habits::structs::models::habit::Habit;

pub async fn get_habit_by_id(
    conn: &mut PgConnection,
    habit_id: Uuid,
) -> Result<Option<Habit>, sqlx::Error> {
    sqlx::query_as!(
        Habit,
        r#"
        SELECT *
        from habits
        WHERE id = $1
        "#,
        habit_id,
    )
    .fetch_optional(conn)
    .await
}

pub async fn get_habits(conn: &mut PgConnection) -> Result<Vec<Habit>, sqlx::Error> {
    sqlx::query_as!(
        Habit,
        r#"
        SELECT *
        from habits
        "#,
    )
    .fetch_all(conn)
    .await
}

pub async fn get_reviewed_and_personnal_habits(
    conn: &mut PgConnection,
    user_id: Uuid,
) -> Result<Vec<Habit>, sqlx::Error> {
    sqlx::query_as!(
        Habit,
        r#"
        SELECT DISTINCT
            h.id,
            h.short_name,
            h.long_name,
            h.category_id,
            h.reviewed,
            h.description,
            h.icon,
            h.created_at,
            h.unit_ids
        FROM habits h
        LEFT JOIN habit_participations hp ON h.id = hp.habit_id
        WHERE h.reviewed = true OR hp.user_id = $1;
        "#,
        user_id
    )
    .fetch_all(conn)
    .await
}

pub async fn update_habit(
    conn: &mut PgConnection,
    habit: &Habit,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        Habit,
        r#"
        UPDATE habits
        SET 
            short_name = $1,
            long_name = $2,
            description = $3,
            reviewed = $4,
            icon = $5,
            category_id = $6,
            unit_ids = $7
        WHERE id = $8
        "#,
        habit.short_name,
        habit.long_name,
        habit.description,
        habit.reviewed,
        habit.icon,
        habit.category_id,
        habit.unit_ids,
        habit.id,
    )
    .execute(conn)
    .await
}

pub async fn create_habit(
    conn: &mut PgConnection,
    habit: &Habit,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        Habit,
        r#"
        INSERT INTO habits (
            id,
            short_name,
            long_name,
            description,
            reviewed,
            created_at,
            icon,
            category_id,
            unit_ids
        )
        VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9 )
        "#,
        habit.id,
        habit.short_name,
        habit.long_name,
        habit.description,
        habit.reviewed,
        habit.created_at,
        habit.icon,
        habit.category_id,
        habit.unit_ids
    )
    .execute(conn)
    .await
}

pub async fn delete_habit_by_id(
    conn: &mut PgConnection,
    habit_id: Uuid,
) -> Result<PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        Habit,
        r#"
        DELETE
        from habits
        WHERE id = $1
        "#,
        habit_id,
    )
    .execute(conn)
    .await
}
