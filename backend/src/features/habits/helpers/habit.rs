use std::collections::HashSet;

use sqlx::{postgres::PgQueryResult, PgConnection, PgPool};
use uuid::Uuid;

use crate::features::habits::structs::models::{habit::Habit, habit_statistics::HabitStatistics};

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

pub async fn fetch_habit_statistics(pool: &PgPool) -> Result<Vec<HabitStatistics>, sqlx::Error> {
    let mut transaction = pool.begin().await?;

    let habits = get_habits(&mut transaction).await?;
    let habit_ids: Vec<_> = habits.iter().map(|h| h.id).collect();

    let counts = sqlx::query!(
        r#"
            SELECT habit_id, count(*) as "count!"
            FROM habit_participations
            WHERE habit_id = ANY($1)
            GROUP BY habit_id
        "#,
        &habit_ids
    )
    .fetch_all(pool)
    .await?;

    let ages = sqlx::query!(
        r#"
            SELECT habit_id, u.age_category, count(*) as "count!"
            FROM habit_participations hp
            LEFT JOIN users u ON hp.user_id = u.id
            WHERE u.age_category IS NOT NULL
            GROUP BY habit_id, u.age_category
        "#,
    )
    .fetch_all(pool)
    .await?;

    let activities = sqlx::query!(
        r#"
            SELECT habit_id, u.activity, count(*) as "count!"
            FROM habit_participations hp
            LEFT JOIN users u ON hp.user_id = u.id
            WHERE u.activity IS NOT NULL
            GROUP BY habit_id, u.activity
        "#,
    )
    .fetch_all(pool)
    .await?;

    let countries = sqlx::query!(
        r#"
            SELECT habit_id, u.country, count(*) as "count!"
            FROM habit_participations hp
            LEFT JOIN users u ON hp.user_id = u.id
            WHERE u.country IS NOT NULL
            GROUP BY habit_id, u.country
        "#,
    )
    .fetch_all(pool)
    .await?;

    let regions = sqlx::query!(
        r#"
            SELECT habit_id, u.region, count(*) as "count!"
            FROM habit_participations hp
            LEFT JOIN users u ON hp.user_id = u.id
            WHERE u.region IS NOT NULL
            GROUP BY habit_id, u.region
        "#,
    )
    .fetch_all(pool)
    .await?;

    let financial_situations = sqlx::query!(
        r#"
            SELECT habit_id, u.financial_situation, count(*) as "count!"
            FROM habit_participations hp
            LEFT JOIN users u ON hp.user_id = u.id
            WHERE u.financial_situation IS NOT NULL
            GROUP BY habit_id, u.financial_situation
        "#,
    )
    .fetch_all(pool)
    .await?;

    let genders = sqlx::query!(
        r#"
            SELECT habit_id, u.gender, count(*) as "count!"
            FROM habit_participations hp
            LEFT JOIN users u ON hp.user_id = u.id
            WHERE u.gender IS NOT NULL
            GROUP BY habit_id, u.gender
        "#,
    )
    .fetch_all(pool)
    .await?;

    let childrens = sqlx::query!(
        r#"
            SELECT habit_id, u.has_children, count(*) as "count!"
            FROM habit_participations hp
            LEFT JOIN users u ON hp.user_id = u.id
            WHERE u.has_children IS NOT NULL
            GROUP BY habit_id, u.has_children
        "#,
    )
    .fetch_all(pool)
    .await?;

    let educations = sqlx::query!(
        r#"
            SELECT habit_id, u.level_of_education, count(*) as "count!"
            FROM habit_participations hp
            LEFT JOIN users u ON hp.user_id = u.id
            WHERE u.level_of_education IS NOT NULL
            GROUP BY habit_id, u.level_of_education
        "#,
    )
    .fetch_all(pool)
    .await?;

    let urban_areas = sqlx::query!(
        r#"
            SELECT habit_id, u.lives_in_urban_area, count(*) as "count!"
            FROM habit_participations hp
            LEFT JOIN users u ON hp.user_id = u.id
            WHERE u.lives_in_urban_area IS NOT NULL
            GROUP BY habit_id, u.lives_in_urban_area
        "#,
    )
    .fetch_all(pool)
    .await?;

    let relations = sqlx::query!(
        r#"
            SELECT habit_id, u.relationship_status, count(*) as "count!"
            FROM habit_participations hp
            LEFT JOIN users u ON hp.user_id = u.id
            WHERE u.relationship_status IS NOT NULL
            GROUP BY habit_id, u.relationship_status
        "#,
    )
    .fetch_all(pool)
    .await?;

    // Process results
    let mut statistics = Vec::new();

    for habit in habits {
        // Get participant count for the current habit
        let participant_count = counts
            .iter()
            .find(|c| c.habit_id == habit.id)
            .map(|c| c.count)
            .unwrap_or(0);

        // Collect age statistics for the current habit
        let age_data: HashSet<(String, i64)> = ages
            .iter()
            .filter(|a| a.habit_id == habit.id)
            .filter_map(|a| a.age_category.as_ref().map(|age| (age.clone(), a.count)))
            .collect();

        // Collect activity statistics for the current habit
        let activity_data: HashSet<(String, i64)> = activities
            .iter()
            .filter(|a| a.habit_id == habit.id)
            .filter_map(|a| {
                a.activity
                    .as_ref()
                    .map(|activity| (activity.clone(), a.count))
            })
            .collect();

        // Collect country statistics for the current habit
        let country_data: HashSet<(String, i64)> = countries
            .iter()
            .filter(|c| c.habit_id == habit.id)
            .filter_map(|c| c.country.as_ref().map(|country| (country.clone(), c.count)))
            .collect();

        // Collect region statistics for the current habit
        let region_data: HashSet<(String, i64)> = regions
            .iter()
            .filter(|r| r.habit_id == habit.id)
            .filter_map(|r| r.region.as_ref().map(|region| (region.clone(), r.count)))
            .collect();

        // Collect financial situation statistics for the current habit
        let financial_situation_data: HashSet<(String, i64)> = financial_situations
            .iter()
            .filter(|f| f.habit_id == habit.id)
            .filter_map(|f| {
                f.financial_situation
                    .as_ref()
                    .map(|fs| (fs.clone(), f.count))
            })
            .collect();

        // Collect gender statistics for the current habit
        let gender_data: HashSet<(String, i64)> = genders
            .iter()
            .filter(|g| g.habit_id == habit.id)
            .filter_map(|g| g.gender.as_ref().map(|gender| (gender.clone(), g.count)))
            .collect();

        // Collect has_children statistics for the current habit
        let children_data: HashSet<(String, i64)> = childrens
            .iter()
            .filter(|ch| ch.habit_id == habit.id)
            .filter_map(|ch| {
                ch.has_children.as_ref().map(|children| {
                    (
                        if *children {
                            "Yes".to_string()
                        } else {
                            "No".to_string()
                        },
                        ch.count,
                    )
                })
            })
            .collect();

        // Collect level_of_education statistics for the current habit
        let education_data: HashSet<(String, i64)> = educations
            .iter()
            .filter(|e| e.habit_id == habit.id)
            .filter_map(|e| {
                e.level_of_education
                    .as_ref()
                    .map(|edu| (edu.clone(), e.count))
            })
            .collect();

        // Collect lives_in_urban_area statistics for the current habit
        let urban_area_data: HashSet<(String, i64)> = urban_areas
            .iter()
            .filter(|u| u.habit_id == habit.id)
            .filter_map(|u| {
                u.lives_in_urban_area.as_ref().map(|urban| {
                    (
                        if *urban {
                            "Yes".to_string()
                        } else {
                            "No".to_string()
                        },
                        u.count,
                    )
                })
            })
            .collect();

        // Collect relationship_status statistics for the current habit
        let relationship_status_data: HashSet<(String, i64)> = relations
            .iter()
            .filter(|rel| rel.habit_id == habit.id)
            .filter_map(|rel| {
                rel.relationship_status
                    .as_ref()
                    .map(|rel_status| (rel_status.clone(), rel.count))
            })
            .collect();

        // Create a HabitStatistics entry
        statistics.push(HabitStatistics {
            habit_id: habit.id,
            participants_count: participant_count,
            top_ages: age_data,
            top_activities: activity_data,
            top_countries: country_data,
            top_financial_situations: financial_situation_data,
            top_gender: gender_data,
            top_has_children: children_data,
            top_levels_of_education: education_data,
            top_lives_in_urban_area: urban_area_data,
            top_regions: region_data,
            top_relationship_statuses: relationship_status_data,
        });
    }

    Ok(statistics)
}
