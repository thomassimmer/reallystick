use std::collections::HashMap;

use argon2::PasswordHasher;
use argon2::{password_hash::SaltString, Argon2};
use chrono::{Duration, Utc};
use rand::rngs::OsRng;
use serde_json::json;
use sqlx::PgPool;
use uuid::Uuid;

use crate::features::habits::helpers::habit::create_habit;
use crate::features::habits::helpers::habit_category::create_habit_category;
use crate::features::habits::helpers::habit_daily_tracking::create_habit_daily_tracking;
use crate::features::habits::helpers::habit_participation::create_habit_participation;
use crate::features::habits::structs::models::habit_daily_tracking::HabitDailyTracking;
use crate::features::habits::structs::models::habit_participation::HabitParticipation;
use crate::features::profile::helpers::user::create_user;
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
        username: "thomas".to_string(),
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

    let _ = create_user(&mut transaction, new_user.clone()).await;

    let habit_categories = [
        HabitCategory {
            id: Uuid::new_v4(),
            name: json!(HashMap::from([("en", "Health"), ("fr", "Santé")])).to_string(),
            icon: "material::health_and_safety".to_string(),
            created_at: Utc::now(),
        },
        HabitCategory {
            id: Uuid::new_v4(),
            name: json!(HashMap::from([
                ("en", "Learning languages"),
                ("fr", "Apprentissage des langues")
            ]))
            .to_string(),
            icon: "material::language".to_string(),
            created_at: Utc::now(),
        },
        HabitCategory {
            id: Uuid::new_v4(),
            name: json!(HashMap::from([("en", "Lifestyle"), ("fr", "Style de vie")])).to_string(),
            icon: "material::self_improvement".to_string(),
            created_at: Utc::now(),
        },
        HabitCategory {
            id: Uuid::new_v4(),
            name: json!(HashMap::from([("en", "Sport"), ("fr", "Sport")])).to_string(),
            icon: "material::fitness_center".to_string(),
            created_at: Utc::now(),
        },
        HabitCategory {
            id: Uuid::new_v4(),
            name: json!(HashMap::from([("en", "Finance"), ("fr", "Finance")])).to_string(),
            icon: "material::paid".to_string(),
            created_at: Utc::now(),
        },
    ];

    for habit_category in habit_categories.clone() {
        create_habit_category(&mut *transaction, &habit_category).await?;
    }

    let habits = [
        Habit {
            id: Uuid::new_v4(),
            category_id: habit_categories[0].id,
            short_name: json!(HashMap::from([("en", "Smoking"), ("fr", "Fumer")])).to_string(),
            long_name: json!(HashMap::from([
                ("en", "Quit smoking"),
                ("fr", "Arrêter de fumer")
            ]))
            .to_string(),
            description: json!(HashMap::from([
                ("en", "To quit smoking, it's here!"),
                ("fr", "Pour arrêter de fumer, ça se passe ici !")
            ]))
            .to_string(),
            reviewed: true,
            created_at: Utc::now(),
            icon: "material::smoke_free".to_string(),
        },
        Habit {
            id: Uuid::new_v4(),
            category_id: habit_categories[1].id,
            short_name: json!(HashMap::from([("en", "English"), ("fr", "Anglais"),])).to_string(),
            long_name: json!(HashMap::from([
                ("en", "Learn English"),
                ("fr", "Apprentissage de l'anglais"),
            ]))
            .to_string(),
            description: json!(HashMap::from([
                (
                    "en",
                    "This habit is for people who want to speak English fluently!"
                ),
                (
                    "fr",
                    "Cette habitude est pour les gens qui veulent parler anglais couramment !"
                )
            ]))
            .to_string(),
            reviewed: true,
            created_at: Utc::now(),
            icon: "web::https://flagcdn.com/w320/gb.png".to_string(),
        },
        Habit {
            id: Uuid::new_v4(),
            category_id: habit_categories[1].id,
            short_name: json!(HashMap::from([("en", "French"), ("fr", "Français")])).to_string(),
            long_name: json!(HashMap::from([
                ("en", "Learn French"),
                ("fr", "Apprentissage du français")
            ]))
            .to_string(),
            description: json!(HashMap::from([
                (
                    "en",
                    "This habit is for people who want to speak French fluently!"
                ),
                (
                    "fr",
                    "Cette habitude est pour les gens qui veulent parler français couramment !"
                )
            ]))
            .to_string(),
            reviewed: true,
            created_at: Utc::now(),
            icon: "web::https://flagcdn.com/w320/fr.png".to_string(),
        },
        Habit {
            id: Uuid::new_v4(),
            category_id: habit_categories[2].id,
            short_name: json!(HashMap::from([("en", "Video games"), ("fr", "Jeux vidéo")]))
                .to_string(),
            long_name: json!(HashMap::from([
                ("en", "Play less video games"),
                ("fr", "Moins jouer aux jeux vidéo")
            ]))
            .to_string(),
            description: json!(HashMap::from([
                (
                    "en",
                    "For people who would like to reduce their time playing video games!"
                ),
                (
                    "fr",
                    "Pour ceux qui veulent réduire le temps passé à jouer aux jeux vidéo !"
                )
            ]))
            .to_string(),
            reviewed: true,
            created_at: Utc::now(),
            icon: "material::sports_esports".to_string(),
        },
        Habit {
            id: Uuid::new_v4(),
            category_id: habit_categories[3].id,
            short_name: json!(HashMap::from([("en", "Weight"), ("fr", "Poids")])).to_string(),
            long_name: json!(HashMap::from([
                ("en", "Weight tracking"),
                ("fr", "Suivi du poids")
            ]))
            .to_string(),
            description: json!(HashMap::from([
                (
                    "en",
                    "For people who would like to lose or gain some weight!"
                ),
                ("fr", "Pour ceux qui veulent perdre ou gagner du poids !")
            ]))
            .to_string(),
            reviewed: true,
            created_at: Utc::now(),
            icon: "material::monitor_weight".to_string(),
        },
        Habit {
            id: Uuid::new_v4(),
            category_id: habit_categories[3].id,
            short_name: json!(HashMap::from([("en", "Workout"), ("fr", "Musculation")]))
                .to_string(),
            long_name: json!(HashMap::from([
                ("en", "Workout tracking"),
                ("fr", "Suivi des efforts en musculation")
            ]))
            .to_string(),
            description: json!(HashMap::from([
                (
                    "en",
                    "For people who would like to monitor their workout performances!"
                ),
                (
                    "fr",
                    "Pour ceux qui veulent surveiller leurs performances en musculation !"
                )
            ]))
            .to_string(),
            reviewed: true,
            created_at: Utc::now(),
            icon: "material::fitness_center".to_string(),
        },
        Habit {
            id: Uuid::new_v4(),
            category_id: habit_categories[4].id,
            short_name: json!(HashMap::from([
                ("en", "Saving money"),
                ("fr", "Économiser")
            ]))
            .to_string(),
            long_name: json!(HashMap::from([
                ("en", "Spending less money"),
                ("fr", "Dépenser moins d'argent")
            ]))
            .to_string(),
            description: json!(HashMap::from([
                (
                    "en",
                    "For people who would like to reduce their money spending!"
                ),
                (
                    "fr",
                    "Pour ceux qui veulent surveiller leurs porte-monnaie !"
                )
            ]))
            .to_string(),
            reviewed: true,
            created_at: Utc::now(),
            icon: "material::savings".to_string(),
        },
    ];

    for habit in habits.clone() {
        create_habit(&mut transaction, &habit).await?;
    }

    let habit_participations = [
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits[0].id,
            user_id: new_user.id,
            color: "blue".to_string(),
            to_gain: false,
            created_at: Utc::now(),
        },
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits[1].id,
            user_id: new_user.id,
            color: "yellow".to_string(),
            to_gain: true,
            created_at: Utc::now(),
        },
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits[4].id,
            user_id: new_user.id,
            color: "green".to_string(),
            to_gain: true,
            created_at: Utc::now(),
        },
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits[5].id,
            user_id: new_user.id,
            color: "green".to_string(),
            to_gain: true,
            created_at: Utc::now(),
        },
    ];

    for habit_participation in habit_participations {
        create_habit_participation(&mut transaction, &habit_participation).await?;
    }

    let habit_daily_trackings = [
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits[0].id,
            user_id: new_user.id,
            day: (Utc::now() - Duration::days(8)).date_naive(),
            created_at: Utc::now() - Duration::days(8),
            duration: None,
            quantity_of_set: None,
            quantity_per_set: None,
            unit: None,
            reset: true,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits[0].id,
            user_id: new_user.id,
            day: (Utc::now() - Duration::days(3)).date_naive(),
            created_at: Utc::now() - Duration::days(3),
            duration: None,
            quantity_of_set: None,
            quantity_per_set: None,
            unit: None,
            reset: true,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits[1].id,
            user_id: new_user.id,
            day: Utc::now().date_naive(),
            created_at: Utc::now(),
            duration: Some(Duration::minutes(30)),
            quantity_of_set: None,
            quantity_per_set: None,
            unit: None,
            reset: false,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits[1].id,
            user_id: new_user.id,
            day: (Utc::now() - Duration::days(1)).date_naive(),
            created_at: Utc::now() - Duration::days(1),
            duration: Some(Duration::minutes(10)),
            quantity_of_set: None,
            quantity_per_set: None,
            unit: None,
            reset: false,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits[1].id,
            user_id: new_user.id,
            day: (Utc::now() - Duration::days(2)).date_naive(),
            created_at: Utc::now() - Duration::days(2),
            duration: Some(Duration::minutes(60)),
            quantity_of_set: None,
            quantity_per_set: None,
            unit: None,
            reset: false,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits[4].id,
            user_id: new_user.id,
            day: (Utc::now() - Duration::days(7)).date_naive(),
            created_at: Utc::now() - Duration::days(7),
            duration: None,
            quantity_of_set: Some(70),
            quantity_per_set: None,
            unit: Some("kg".to_string()),
            reset: false,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits[4].id,
            user_id: new_user.id,
            day: (Utc::now() - Duration::days(1)).date_naive(),
            created_at: Utc::now() - Duration::days(1),
            duration: None,
            quantity_of_set: Some(71),
            quantity_per_set: None,
            unit: Some("kg".to_string()),
            reset: false,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits[5].id,
            user_id: new_user.id,
            day: Utc::now().date_naive(),
            created_at: Utc::now(),
            duration: None,
            quantity_of_set: Some(10),
            quantity_per_set: Some(4),
            unit: Some("push-ups".to_string()),
            reset: false,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits[5].id,
            user_id: new_user.id,
            day: Utc::now().date_naive(),
            created_at: Utc::now(),
            duration: None,
            quantity_of_set: Some(7),
            quantity_per_set: Some(5),
            unit: Some("pull-ups".to_string()),
            reset: false,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits[5].id,
            user_id: new_user.id,
            day: (Utc::now() - Duration::days(2)).date_naive(),
            created_at: Utc::now() - Duration::days(2),
            duration: None,
            quantity_of_set: Some(10),
            quantity_per_set: Some(5),
            unit: Some("push-ups".to_string()),
            reset: false,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits[5].id,
            user_id: new_user.id,
            day: (Utc::now() - Duration::days(2)).date_naive(),
            created_at: Utc::now() - Duration::days(2),
            duration: None,
            quantity_of_set: Some(10),
            quantity_per_set: Some(4),
            unit: Some("dips".to_string()),
            reset: false,
        },
    ];

    for habit_daily_tracking in habit_daily_trackings {
        create_habit_daily_tracking(&mut transaction, &habit_daily_tracking).await?;
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
