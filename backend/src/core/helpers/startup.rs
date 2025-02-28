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
use crate::features::habits::helpers::unit::create_unit;
use crate::features::habits::structs::models::habit_daily_tracking::HabitDailyTracking;
use crate::features::habits::structs::models::habit_participation::HabitParticipation;
use crate::features::habits::structs::models::unit::Unit;
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
        is_admin: true,
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

    let units = HashMap::from([
        (
            "no_unit",
            Unit {
                id: Uuid::new_v4(),
                short_name: json!(HashMap::from([("en", ""), ("fr", "")])).to_string(),
                long_name: json!(HashMap::from([
                    ("en", HashMap::from([("one", ""), ("other", "No unit")])),
                    ("fr", HashMap::from([("one", ""), ("other", "Sans unité")]))
                ]))
                .to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "hour",
            Unit {
                id: Uuid::new_v4(),
                short_name: json!(HashMap::from([("en", "h"), ("fr", "h")])).to_string(),
                long_name: json!(HashMap::from([
                    ("en", HashMap::from([("one", "hour"), ("other", "hours")])),
                    ("fr", HashMap::from([("one", "heure"), ("other", "heures")]))
                ]))
                .to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "minute",
            Unit {
                id: Uuid::new_v4(),
                short_name: json!(HashMap::from([("en", "min"), ("fr", "min")])).to_string(),
                long_name: json!(HashMap::from([
                    (
                        "en",
                        HashMap::from([("one", "minute"), ("other", "minutes")])
                    ),
                    (
                        "fr",
                        HashMap::from([("one", "minute"), ("other", "minutes")])
                    )
                ]))
                .to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "second",
            Unit {
                id: Uuid::new_v4(),
                short_name: json!(HashMap::from([("en", "s"), ("fr", "s")])).to_string(),
                long_name: json!(HashMap::from([
                    (
                        "en",
                        HashMap::from([("one", "second"), ("other", "seconds")])
                    ),
                    (
                        "fr",
                        HashMap::from([("one", "seconde"), ("other", "secondes")])
                    )
                ]))
                .to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "meter",
            Unit {
                id: Uuid::new_v4(),
                short_name: json!(HashMap::from([("en", "m"), ("fr", "m")])).to_string(),
                long_name: json!(HashMap::from([
                    ("en", HashMap::from([("one", "meter"), ("other", "meters")])),
                    ("fr", HashMap::from([("one", "mètre"), ("other", "mètres")]))
                ]))
                .to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "kilometer",
            Unit {
                id: Uuid::new_v4(),
                short_name: json!(HashMap::from([("en", "km"), ("fr", "km")])).to_string(),
                long_name: json!(HashMap::from([
                    (
                        "en",
                        HashMap::from([("one", "kilometer"), ("other", "kilometers")])
                    ),
                    (
                        "fr",
                        HashMap::from([("one", "kilomètre"), ("other", "kilomètres")])
                    )
                ]))
                .to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "gram",
            Unit {
                id: Uuid::new_v4(),
                short_name: json!(HashMap::from([("en", "g"), ("fr", "g")])).to_string(),
                long_name: json!(HashMap::from([
                    ("en", HashMap::from([("one", "gram"), ("other", "grams")])),
                    (
                        "fr",
                        HashMap::from([("one", "gramme"), ("other", "grammes")])
                    )
                ]))
                .to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "kilogram",
            Unit {
                id: Uuid::new_v4(),
                short_name: json!(HashMap::from([("en", "kg"), ("fr", "kg")])).to_string(),
                long_name: json!(HashMap::from([
                    (
                        "en",
                        HashMap::from([("one", "kilogram"), ("other", "kilograms")])
                    ),
                    (
                        "fr",
                        HashMap::from([("one", "kilogramme"), ("other", "kilogrammes")])
                    )
                ]))
                .to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "kcal",
            Unit {
                id: Uuid::new_v4(),
                short_name: json!(HashMap::from([("en", "kcal"), ("fr", "kcal")])).to_string(),
                long_name: json!(HashMap::from([
                    (
                        "en",
                        HashMap::from([("one", "kilocalory"), ("other", "kilocalories")])
                    ),
                    (
                        "fr",
                        HashMap::from([("one", "kilocalorie"), ("other", "kilocalories")])
                    )
                ]))
                .to_string(),
                created_at: Utc::now(),
            },
        ),
    ]);

    for unit in units.values().clone() {
        create_unit(&mut transaction, unit).await?;
    }

    let _ = create_user(&mut transaction, new_user.clone()).await;

    let habit_categories = HashMap::from([
        (
            "health",
            HabitCategory {
                id: Uuid::new_v4(),
                name: json!(HashMap::from([("en", "Health"), ("fr", "Santé")])).to_string(),
                icon: "material::58117".to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "languages",
            HabitCategory {
                id: Uuid::new_v4(),
                name: json!(HashMap::from([
                    ("en", "Learning languages"),
                    ("fr", "Apprentissage des langues")
                ]))
                .to_string(),
                icon: "material::58214".to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "lifestyle",
            HabitCategory {
                id: Uuid::new_v4(),
                name: json!(HashMap::from([("en", "Lifestyle"), ("fr", "Style de vie")]))
                    .to_string(),
                icon: "material::58735".to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "sport",
            HabitCategory {
                id: Uuid::new_v4(),
                name: json!(HashMap::from([("en", "Sport"), ("fr", "Sport")])).to_string(),
                icon: "material::57997".to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "finance",
            HabitCategory {
                id: Uuid::new_v4(),
                name: json!(HashMap::from([("en", "Finance"), ("fr", "Finance")])).to_string(),
                icon: "material::57522".to_string(),
                created_at: Utc::now(),
            },
        ),
    ]);

    for habit_category in habit_categories.values().clone() {
        create_habit_category(&mut transaction, habit_category).await?;
    }

    let habits = HashMap::from([
        (
            "smoking",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("health").unwrap().id,
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
                icon: "material::58823".to_string(),
                unit_ids: json!(vec![units.get("no_unit").unwrap().id]).to_string(),
            },
        ),
        (
            "english",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("languages").unwrap().id,
                short_name: json!(HashMap::from([("en", "English"), ("fr", "Anglais"),]))
                    .to_string(),
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
                unit_ids: json!(vec![
                    units.get("hour").unwrap().id,
                    units.get("minute").unwrap().id
                ])
                .to_string(),
            },
        ),
        (
            "french",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("languages").unwrap().id,
                short_name: json!(HashMap::from([("en", "French"), ("fr", "Français")]))
                    .to_string(),
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
                unit_ids: json!(vec![
                    units.get("hour").unwrap().id,
                    units.get("minute").unwrap().id
                ])
                .to_string(),
            },
        ),
        (
            "videogames",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("lifestyle").unwrap().id,
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
                icon: "material::58856".to_string(),
                unit_ids: json!(vec![
                    units.get("hour").unwrap().id,
                    units.get("minute").unwrap().id
                ])
                .to_string(),
            },
        ),
        (
            "weight",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("health").unwrap().id,
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
                icon: "material::58364".to_string(),
                unit_ids: json!(vec![
                    units.get("kilogram").unwrap().id,
                    units.get("gram").unwrap().id,
                    units.get("kcal").unwrap().id
                ])
                .to_string(),
            },
        ),
        (
            "workout",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("sport").unwrap().id,
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
                icon: "material::57997".to_string(),
                unit_ids: json!(vec![
                    units.get("hour").unwrap().id,
                    units.get("minute").unwrap().id
                ])
                .to_string(),
            },
        ),
        (
            "pushups",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("sport").unwrap().id,
                short_name: json!(HashMap::from([("en", "Push-ups"), ("fr", "Pompes")]))
                    .to_string(),
                long_name: json!(HashMap::from([
                    ("en", "Push-ups tracking"),
                    ("fr", "Suivi des pompes")
                ]))
                .to_string(),
                description: json!(HashMap::from([
                    (
                        "en",
                        "For people who would like to monitor their performances in push-ups!"
                    ),
                    (
                        "fr",
                        "Pour ceux qui veulent surveiller leurs performances en pompe !"
                    )
                ]))
                .to_string(),
                reviewed: true,
                created_at: Utc::now(),
                icon: "material::57997".to_string(),
                unit_ids: json!(vec![units.get("no_unit").unwrap().id]).to_string(),
            },
        ),
        (
            "pullups",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("sport").unwrap().id,
                short_name: json!(HashMap::from([("en", "Pull-ups"), ("fr", "Tractions")]))
                    .to_string(),
                long_name: json!(HashMap::from([
                    ("en", "Pull-ups tracking"),
                    ("fr", "Suivi des tractions")
                ]))
                .to_string(),
                description: json!(HashMap::from([
                    (
                        "en",
                        "For people who would like to monitor their performances in pull-ups!"
                    ),
                    (
                        "fr",
                        "Pour ceux qui veulent surveiller leurs performances en traction !"
                    )
                ]))
                .to_string(),
                reviewed: true,
                created_at: Utc::now(),
                icon: "material::57997".to_string(),
                unit_ids: json!(vec![units.get("no_unit").unwrap().id]).to_string(),
            },
        ),
        (
            "saving",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("finance").unwrap().id,
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
                icon: "material::58707".to_string(),
                unit_ids: json!(vec![units.get("no_unit").unwrap().id]).to_string(),
            },
        ),
    ]);

    for habit in habits.values().clone() {
        create_habit(&mut transaction, habit).await?;
    }

    let habit_participations = [
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits.get("smoking").unwrap().id,
            user_id: new_user.id,
            color: "blue".to_string(),
            to_gain: false,
            created_at: Utc::now(),
        },
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits.get("english").unwrap().id,
            user_id: new_user.id,
            color: "yellow".to_string(),
            to_gain: true,
            created_at: Utc::now(),
        },
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits.get("weight").unwrap().id,
            user_id: new_user.id,
            color: "green".to_string(),
            to_gain: true,
            created_at: Utc::now(),
        },
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits.get("pullups").unwrap().id,
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
            habit_id: habits.get("smoking").unwrap().id,
            user_id: new_user.id,
            datetime: Utc::now() - Duration::days(8),
            created_at: Utc::now() - Duration::days(8),
            quantity_of_set: 1,
            quantity_per_set: 1,
            unit_id: units.get("no_unit").unwrap().id,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("smoking").unwrap().id,
            user_id: new_user.id,
            datetime: Utc::now() - Duration::days(3),
            created_at: Utc::now() - Duration::days(3),
            quantity_of_set: 1,
            quantity_per_set: 1,
            unit_id: units.get("no_unit").unwrap().id,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("english").unwrap().id,
            user_id: new_user.id,
            datetime: Utc::now(),
            created_at: Utc::now(),
            quantity_of_set: 1,
            quantity_per_set: 1,
            unit_id: units.get("hour").unwrap().id,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("english").unwrap().id,
            user_id: new_user.id,
            datetime: Utc::now() - Duration::days(1),
            created_at: Utc::now() - Duration::days(1),
            quantity_of_set: 30,
            quantity_per_set: 1,
            unit_id: units.get("minute").unwrap().id,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("english").unwrap().id,
            user_id: new_user.id,
            datetime: Utc::now() - Duration::days(2),
            created_at: Utc::now() - Duration::days(2),
            quantity_of_set: 2,
            quantity_per_set: 1,
            unit_id: units.get("hour").unwrap().id,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("weight").unwrap().id,
            user_id: new_user.id,
            datetime: Utc::now() - Duration::days(7),
            created_at: Utc::now() - Duration::days(7),
            quantity_of_set: 70,
            quantity_per_set: 1,
            unit_id: units.get("kilogram").unwrap().id,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("weight").unwrap().id,
            user_id: new_user.id,
            datetime: Utc::now() - Duration::days(1),
            created_at: Utc::now() - Duration::days(1),
            quantity_of_set: 71,
            quantity_per_set: 1,
            unit_id: units.get("kilogram").unwrap().id,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("pullups").unwrap().id,
            user_id: new_user.id,
            datetime: Utc::now(),
            created_at: Utc::now(),
            quantity_of_set: 10,
            quantity_per_set: 4,
            unit_id: units.get("no_unit").unwrap().id,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("pullups").unwrap().id,
            user_id: new_user.id,
            datetime: Utc::now(),
            created_at: Utc::now(),
            quantity_of_set: 7,
            quantity_per_set: 5,
            unit_id: units.get("no_unit").unwrap().id,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("pullups").unwrap().id,
            user_id: new_user.id,
            datetime: Utc::now() - Duration::days(2),
            created_at: Utc::now() - Duration::days(2),
            quantity_of_set: 10,
            quantity_per_set: 5,
            unit_id: units.get("no_unit").unwrap().id,
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
    sqlx::query("DELETE FROM units;").execute(pool).await?;

    Ok(())
}
