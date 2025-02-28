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

pub async fn update_habit(
    conn: &mut PgConnection,
    habit: &Habit,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error> {
    sqlx::query_as!(
        Habit,
        r#"
        UPDATE habits
        SET short_name = $1, long_name = $2, description = $3, reviewed = $4, icon = $5
        WHERE id = $6
        "#,
        habit.short_name,
        habit.long_name,
        habit.description,
        habit.reviewed,
        habit.icon,
        habit.id
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
            category_id
        )
        VALUES ( $1, $2, $3, $4, $5, $6, $7, $8 )
        "#,
        habit.id,
        habit.short_name,
        habit.long_name,
        habit.description,
        habit.reviewed,
        habit.created_at,
        habit.icon,
        habit.category_id
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
