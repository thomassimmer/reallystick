use std::collections::HashMap;

use argon2::PasswordHasher;
use argon2::{password_hash::SaltString, Argon2};
use chrono::Utc;
use rand::rngs::OsRng;
use serde_json::json;
use sqlx::PgPool;
use uuid::Uuid;

use crate::features::{
    habits::structs::models::{habit::Habit, habit_category::HabitCategory},
    profile::structs::models::User,
};

use super::mock_now::now;

pub async fn populate_database(pool: &PgPool) -> Result<(), sqlx::Error> {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(_) => panic!("Can't get a transaction."),
    };

    // Create a user with empty username and password.
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();
    let password_hash = argon2
        .hash_password("".as_bytes(), &salt)
        .unwrap()
        .to_string();

    let new_user = User {
        id: Uuid::new_v4(),
        username: "".to_string(),
        password: password_hash,
        locale: "fr".to_string(),
        theme: "light".to_string(),
        otp_verified: false,
        otp_base32: None,
        otp_auth_url: None,
        created_at: now(),
        updated_at: now(),
        recovery_codes: "".to_string(),
        password_is_expired: false,
        has_seen_questions: false,
        age_category: None,
        gender: None,
        continent: None,
        country: None,
        region: None,
        activity: None,
        financial_situation: None,
        lives_in_urban_area: None,
        relationship_status: None,
        level_of_education: None,
        has_children: None,
    };

    let _ = sqlx::query!(
        r#"
            INSERT INTO users (
                id,
                username,
                password,
                otp_verified,
                otp_base32,
                otp_auth_url,
                created_at,
                updated_at,
                recovery_codes,
                password_is_expired
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            "#,
        new_user.id,
        new_user.username,
        new_user.password,
        new_user.otp_verified,
        new_user.otp_base32,
        new_user.otp_auth_url,
        new_user.created_at,
        new_user.updated_at,
        new_user.recovery_codes,
        new_user.password_is_expired
    )
    .execute(&mut *transaction)
    .await;

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

    if let Err(e) = transaction.commit().await {
        eprintln!("Error: {}", e);
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
