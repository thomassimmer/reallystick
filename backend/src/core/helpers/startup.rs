use std::collections::HashMap;

use chrono::Utc;
use serde_json::json;
use sqlx::PgPool;
use uuid::Uuid;

use crate::features::habits::structs::models::{habit::Habit, habit_category::HabitCategory};

pub async fn populate_database(pool: &PgPool) -> Result<(), sqlx::Error> {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(_) => panic!("Can't get a transaction."),
    };

    // Check and insert Habit Categories if none exist
    let category_count: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM habit_categories")
        .fetch_one(pool)
        .await?;

    if category_count.0 == 0 {
        return Ok(());
    }

    let categories = [
        HabitCategory {
            id: Uuid::new_v4(),
            name: json!(HashMap::from([("en", "Health")])).to_string(),
            icon: "health_icon".to_string(),
            created_at: Utc::now(),
        },
        HabitCategory {
            id: Uuid::new_v4(),
            name: json!(HashMap::from([("en", "Learning languages")])).to_string(),
            icon: "language_icon".to_string(),
            created_at: Utc::now(),
        },
        HabitCategory {
            id: Uuid::new_v4(),
            name: json!(HashMap::from([("en", "Lifestyle")])).to_string(),
            icon: "lifestyle_icon".to_string(),
            created_at: Utc::now(),
        },
    ];

    for category in categories.clone() {
        sqlx::query!(
            r#"
                INSERT INTO habit_categories (id, name, icon, created_at)
                VALUES 
                    ($1, $2, $3, $4)
                "#,
            category.id,
            category.name,
            category.icon,
            category.created_at,
        )
        .execute(&mut *transaction)
        .await?;
    }

    let habits = [
        Habit {
            id: Uuid::new_v4(),
            category_id: categories[0].id,
            short_name: json!(HashMap::from([("en", "English")])).to_string(),
            long_name: json!(HashMap::from([("en", "Learn English")])).to_string(),
            description: json!(HashMap::from([(
                "en",
                "Our goal is to speak English fluently!"
            )]))
            .to_string(),
            reviewed: true,
            created_at: Utc::now(),
            icon: "english_icon".to_string(),
        },
        Habit {
            id: Uuid::new_v4(),
            category_id: categories[0].id,
            short_name: json!(HashMap::from([("en", "French")])).to_string(),
            long_name: json!(HashMap::from([("en", "Learn French")])).to_string(),
            description: json!(HashMap::from([(
                "en",
                "Our goal is to speak French fluently!"
            )]))
            .to_string(),
            reviewed: true,
            created_at: Utc::now(),
            icon: "french_icon".to_string(),
        },
    ];

    for habit in habits {
        sqlx::query!(
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
            VALUES 
                ($1, $2, $3, $4, $5, $6, $7, $8)
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
        .execute(&mut *transaction)
        .await?;
    }

    Ok(())
}

pub async fn reset_database(pool: &PgPool) -> Result<(), sqlx::Error> {
    sqlx::query("DELETE FROM users;").execute(pool).await?;
    sqlx::query("DELETE FROM user_tokens;")
        .execute(pool)
        .await?;
    sqlx::query("DELETE FROM habits;").execute(pool).await?;
    sqlx::query("DELETE FROM habit_categories;")
        .execute(pool)
        .await?;

    Ok(())
}
