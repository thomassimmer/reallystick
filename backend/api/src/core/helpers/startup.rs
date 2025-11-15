use std::collections::HashMap;

use argon2::PasswordHasher;
use argon2::{password_hash::SaltString, Argon2};
use chrono::{Duration, Utc};
use fluent::FluentArgs;
use rand::rngs::OsRng;
use serde_json::json;
use sqlx::PgPool;
use tracing::{error, info};
use uuid::Uuid;

use crate::core::helpers::translation::Translator;
use crate::features::auth::infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl;
use crate::features::habits::domain::entities::habit::Habit;
use crate::features::habits::domain::entities::habit_category::HabitCategory;
use crate::features::habits::domain::entities::habit_daily_tracking::HabitDailyTracking;
use crate::features::habits::domain::entities::habit_participation::HabitParticipation;
use crate::features::habits::domain::entities::unit::Unit;
use crate::features::habits::infrastructure::repositories::{
    habit_category_repository::HabitCategoryRepositoryImpl,
    habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl,
    habit_participation_repository::HabitParticipationRepositoryImpl,
    habit_repository::HabitRepositoryImpl, unit_repository::UnitRepositoryImpl,
};
use crate::features::private_discussions::domain::entities::private_discussion::PrivateDiscussion;
use crate::features::private_discussions::domain::entities::private_discussion_participation::PrivateDiscussionParticipation;
use crate::features::private_discussions::domain::entities::private_message::PrivateMessage;
use crate::features::private_discussions::infrastructure::repositories::{
    private_discussion_participation_repository::PrivateDiscussionParticipationRepositoryImpl,
    private_discussion_repository::PrivateDiscussionRepositoryImpl,
    private_message_repository::PrivateMessageRepositoryImpl,
};
use crate::features::profile::domain::entities::User;
use crate::features::profile::infrastructure::repositories::user_repository::UserRepositoryImpl;

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

    let thomas = User {
        id: Uuid::new_v4(),
        username: "thomas".to_string(),
        password: password_hash.clone(),
        locale: "fr".to_string(),
        theme: "light".to_string(),
        timezone: "America/New_York".to_string(),
        is_admin: true,
        private_key_encrypted: None,
        salt_used_to_derive_key_from_password: None,
        public_key: None,
        otp_verified: false,
        otp_base32: None,
        otp_auth_url: None,
        created_at: now(),
        updated_at: now(),
        deleted_at: None,
        is_deleted: false,
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
        notifications_enabled: false,
        notifications_for_private_messages_enabled: false,
        notifications_for_public_message_liked_enabled: false,
        notifications_for_public_message_replies_enabled: false,
        notifications_user_duplicated_your_challenge_enabled: false,
        notifications_user_joined_your_challenge_enabled: false,
    };

    let reallystick = User {
        id: Uuid::new_v4(),
        username: "reallystick".to_string(),
        password: password_hash,
        locale: "fr".to_string(),
        theme: "light".to_string(),
        timezone: "America/New_York".to_string(),
        is_admin: true,
        private_key_encrypted: None,
        salt_used_to_derive_key_from_password: None,
        public_key: None,
        otp_verified: false,
        otp_base32: None,
        otp_auth_url: None,
        created_at: now(),
        updated_at: now(),
        deleted_at: None,
        is_deleted: false,
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
        notifications_enabled: false,
        notifications_for_private_messages_enabled: false,
        notifications_for_public_message_liked_enabled: false,
        notifications_for_public_message_replies_enabled: false,
        notifications_user_duplicated_your_challenge_enabled: false,
        notifications_user_joined_your_challenge_enabled: false,
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
            "pound",
            Unit {
                id: Uuid::new_v4(),
                short_name: json!(HashMap::from([("en", "lb"), ("fr", "lb")])).to_string(),
                long_name: json!(HashMap::from([
                    ("en", HashMap::from([("one", "pound"), ("other", "pounds")])),
                    ("fr", HashMap::from([("one", "livre"), ("other", "livres")]))
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

    let unit_repo = UnitRepositoryImpl::new(pool.clone());
    for unit in units.values().clone() {
        unit_repo
            .create_with_executor(unit, &mut *transaction)
            .await
            .map_err(|e| sqlx::Error::Configuration(Box::new(std::io::Error::other(e))))?;
    }

    let user_repo = UserRepositoryImpl::new(pool.clone());
    let _ = user_repo
        .create_with_executor(&thomas, &mut *transaction)
        .await;
    let _ = user_repo
        .create_with_executor(&reallystick, &mut *transaction)
        .await;

    let habit_categories = HashMap::from([
        (
            "health",
            HabitCategory {
                id: Uuid::new_v4(),
                name: json!(HashMap::from([("en", "Health"), ("fr", "Santé")])).to_string(),
                icon: "🏥".to_string(),
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
                icon: "🗣️".to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "lifestyle",
            HabitCategory {
                id: Uuid::new_v4(),
                name: json!(HashMap::from([("en", "Lifestyle"), ("fr", "Style de vie")]))
                    .to_string(),
                icon: "😎".to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "sport",
            HabitCategory {
                id: Uuid::new_v4(),
                name: json!(HashMap::from([("en", "Sport"), ("fr", "Sport")])).to_string(),
                icon: "💪".to_string(),
                created_at: Utc::now(),
            },
        ),
        (
            "finance",
            HabitCategory {
                id: Uuid::new_v4(),
                name: json!(HashMap::from([("en", "Finance"), ("fr", "Finance")])).to_string(),
                icon: "🏦".to_string(),
                created_at: Utc::now(),
            },
        ),
    ]);

    for habit_category in habit_categories.values().clone() {
        let habit_category_repo = HabitCategoryRepositoryImpl::new(pool.clone());
        habit_category_repo
            .create_with_executor(habit_category, &mut *transaction)
            .await
            .map_err(|e| sqlx::Error::Configuration(Box::new(std::io::Error::other(e))))?;
    }

    let habits = HashMap::from([
        (
            "smoking",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("health").unwrap().id,
                name: json!(HashMap::from([("en", "Smoking"), ("fr", "Fumer")])).to_string(),
                description: json!(HashMap::from([
                    ("en", "To quit smoking, it's here!"),
                    ("fr", "Pour arrêter de fumer, ça se passe ici !")
                ]))
                .to_string(),
                reviewed: true,
                created_at: Utc::now(),
                icon: "🚭".to_string(),
                unit_ids: json!(vec![units.get("no_unit").unwrap().id]).to_string(),
            },
        ),
        (
            "english",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("languages").unwrap().id,
                name: json!(HashMap::from([("en", "English"), ("fr", "Anglais"),])).to_string(),
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
                icon: "🇬🇧".to_string(),
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
                name: json!(HashMap::from([("en", "French"), ("fr", "Français")])).to_string(),
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
                icon: "🇫🇷".to_string(),
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
                name: json!(HashMap::from([("en", "Video games"), ("fr", "Jeux vidéo")]))
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
                icon: "🎮".to_string(),
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
                name: json!(HashMap::from([("en", "Weight"), ("fr", "Poids")])).to_string(),
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
                icon: "⚖️".to_string(),
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
                name: json!(HashMap::from([("en", "Workout"), ("fr", "Musculation")])).to_string(),
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
                icon: "🏋️‍♀️".to_string(),
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
                name: json!(HashMap::from([("en", "Push-ups"), ("fr", "Pompes")])).to_string(),
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
                icon: "🏋️‍♀️".to_string(),
                unit_ids: json!(vec![units.get("no_unit").unwrap().id]).to_string(),
            },
        ),
        (
            "pullups",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("sport").unwrap().id,
                name: json!(HashMap::from([("en", "Pull-ups"), ("fr", "Tractions")])).to_string(),
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
                icon: "🏋️‍♀️".to_string(),
                unit_ids: json!(vec![units.get("no_unit").unwrap().id]).to_string(),
            },
        ),
        (
            "saving",
            Habit {
                id: Uuid::new_v4(),
                category_id: habit_categories.get("finance").unwrap().id,
                name: json!(HashMap::from([
                    ("en", "Saving money"),
                    ("fr", "Économiser")
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
                icon: "🏋️‍♀️".to_string(),
                unit_ids: json!(vec![units.get("no_unit").unwrap().id]).to_string(),
            },
        ),
    ]);

    for habit in habits.values().clone() {
        let habit_repo = HabitRepositoryImpl::new(pool.clone());
        habit_repo
            .create_with_executor(habit, &mut *transaction)
            .await
            .map_err(|e| sqlx::Error::Configuration(Box::new(std::io::Error::other(e))))?;
    }

    let habit_participations = [
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits.get("smoking").unwrap().id,
            user_id: thomas.id,
            color: "blue".to_string(),
            to_gain: false,
            created_at: Utc::now(),
            notifications_reminder_enabled: false,
            reminder_time: None,
            reminder_body: None,
        },
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits.get("english").unwrap().id,
            user_id: thomas.id,
            color: "yellow".to_string(),
            to_gain: true,
            created_at: Utc::now(),
            notifications_reminder_enabled: false,
            reminder_time: None,
            reminder_body: None,
        },
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits.get("weight").unwrap().id,
            user_id: thomas.id,
            color: "green".to_string(),
            to_gain: true,
            created_at: Utc::now(),
            notifications_reminder_enabled: false,
            reminder_time: None,
            reminder_body: None,
        },
        HabitParticipation {
            id: Uuid::new_v4(),
            habit_id: habits.get("pullups").unwrap().id,
            user_id: thomas.id,
            color: "green".to_string(),
            to_gain: true,
            created_at: Utc::now(),
            notifications_reminder_enabled: false,
            reminder_time: None,
            reminder_body: None,
        },
    ];

    for habit_participation in habit_participations {
        let habit_participation_repo = HabitParticipationRepositoryImpl::new(pool.clone());
        habit_participation_repo
            .create_with_executor(&habit_participation, &mut *transaction)
            .await
            .map_err(|e| sqlx::Error::Configuration(Box::new(std::io::Error::other(e))))?;
    }

    let habit_daily_trackings = [
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("smoking").unwrap().id,
            user_id: thomas.id,
            datetime: Utc::now().naive_utc() - Duration::days(8),
            created_at: Utc::now() - Duration::days(8),
            quantity_of_set: 1,
            quantity_per_set: 1.0,
            unit_id: units.get("no_unit").unwrap().id,
            weight: 0,
            weight_unit_id: units.get("no_unit").unwrap().id,
            challenge_daily_tracking: None,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("smoking").unwrap().id,
            user_id: thomas.id,
            datetime: Utc::now().naive_utc() - Duration::days(3),
            created_at: Utc::now() - Duration::days(3),
            quantity_of_set: 1,
            quantity_per_set: 1.0,
            unit_id: units.get("no_unit").unwrap().id,
            weight: 0,
            weight_unit_id: units.get("no_unit").unwrap().id,
            challenge_daily_tracking: None,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("english").unwrap().id,
            user_id: thomas.id,
            datetime: Utc::now().naive_utc(),
            created_at: Utc::now(),
            quantity_of_set: 1,
            quantity_per_set: 1.0,
            unit_id: units.get("hour").unwrap().id,
            weight: 0,
            weight_unit_id: units.get("no_unit").unwrap().id,
            challenge_daily_tracking: None,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("english").unwrap().id,
            user_id: thomas.id,
            datetime: Utc::now().naive_utc() - Duration::days(1),
            created_at: Utc::now() - Duration::days(1),
            quantity_of_set: 30,
            quantity_per_set: 1.0,
            unit_id: units.get("minute").unwrap().id,
            weight: 0,
            weight_unit_id: units.get("no_unit").unwrap().id,
            challenge_daily_tracking: None,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("english").unwrap().id,
            user_id: thomas.id,
            datetime: Utc::now().naive_utc() - Duration::days(2),
            created_at: Utc::now() - Duration::days(2),
            quantity_of_set: 2,
            quantity_per_set: 1.0,
            unit_id: units.get("hour").unwrap().id,
            weight: 0,
            weight_unit_id: units.get("no_unit").unwrap().id,
            challenge_daily_tracking: None,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("weight").unwrap().id,
            user_id: thomas.id,
            datetime: Utc::now().naive_utc() - Duration::days(7),
            created_at: Utc::now() - Duration::days(7),
            quantity_of_set: 70,
            quantity_per_set: 1.0,
            unit_id: units.get("kilogram").unwrap().id,
            weight: 0,
            weight_unit_id: units.get("no_unit").unwrap().id,
            challenge_daily_tracking: None,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("weight").unwrap().id,
            user_id: thomas.id,
            datetime: Utc::now().naive_utc() - Duration::days(1),
            created_at: Utc::now() - Duration::days(1),
            quantity_of_set: 71,
            quantity_per_set: 1.0,
            unit_id: units.get("kilogram").unwrap().id,
            weight: 0,
            weight_unit_id: units.get("no_unit").unwrap().id,
            challenge_daily_tracking: None,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("pullups").unwrap().id,
            user_id: thomas.id,
            datetime: Utc::now().naive_utc(),
            created_at: Utc::now(),
            quantity_of_set: 10,
            quantity_per_set: 4.0,
            unit_id: units.get("no_unit").unwrap().id,
            weight: 0,
            weight_unit_id: units.get("no_unit").unwrap().id,
            challenge_daily_tracking: None,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("pullups").unwrap().id,
            user_id: thomas.id,
            datetime: Utc::now().naive_utc(),
            created_at: Utc::now(),
            quantity_of_set: 7,
            quantity_per_set: 5.0,
            unit_id: units.get("no_unit").unwrap().id,
            weight: 0,
            weight_unit_id: units.get("no_unit").unwrap().id,
            challenge_daily_tracking: None,
        },
        HabitDailyTracking {
            id: Uuid::new_v4(),
            habit_id: habits.get("pullups").unwrap().id,
            user_id: thomas.id,
            datetime: Utc::now().naive_utc() - Duration::days(2),
            created_at: Utc::now() - Duration::days(2),
            quantity_of_set: 10,
            quantity_per_set: 5.0,
            unit_id: units.get("no_unit").unwrap().id,
            weight: 0,
            weight_unit_id: units.get("no_unit").unwrap().id,
            challenge_daily_tracking: None,
        },
    ];

    for habit_daily_tracking in habit_daily_trackings {
        let habit_daily_tracking_repo = HabitDailyTrackingRepositoryImpl::new(pool.clone());
        habit_daily_tracking_repo
            .create_with_executor(&habit_daily_tracking, &mut *transaction)
            .await
            .map_err(|e| sqlx::Error::Configuration(Box::new(std::io::Error::other(e))))?;
    }

    if let Err(e) = transaction.commit().await {
        error!("Error: {}", e);
    }

    Ok(())
}

pub async fn reset_database(pool: &PgPool) -> Result<(), sqlx::Error> {
    sqlx::query("DELETE FROM user_tokens;")
        .execute(pool)
        .await?;
    sqlx::query("DELETE FROM recovery_codes;")
        .execute(pool)
        .await?;
    sqlx::query("DELETE FROM public_messages;")
        .execute(pool)
        .await?;
    sqlx::query("DELETE FROM private_messages;")
        .execute(pool)
        .await?;
    sqlx::query("DELETE FROM private_discussion_participations;")
        .execute(pool)
        .await?;
    sqlx::query("DELETE FROM private_discussions;")
        .execute(pool)
        .await?;
    sqlx::query("DELETE FROM habits;").execute(pool).await?;
    sqlx::query("DELETE FROM habit_categories;")
        .execute(pool)
        .await?;
    sqlx::query("DELETE FROM challenge_daily_trackings;")
        .execute(pool)
        .await?;
    sqlx::query("DELETE FROM challenge_participations;")
        .execute(pool)
        .await?;
    sqlx::query("DELETE FROM challenges;").execute(pool).await?;
    sqlx::query("DELETE FROM units;").execute(pool).await?;
    sqlx::query("DELETE FROM users;").execute(pool).await?;

    Ok(())
}

pub async fn create_missing_discussions_with_reallystick_user(
    pool: &PgPool,
) -> Result<(), sqlx::Error> {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(_) => panic!("Can't get a transaction."),
    };

    let user_repo = UserRepositoryImpl::new(pool.clone());
    let users = user_repo.get_all_with_executor(&mut *transaction).await?;

    let reallystick_user = user_repo
        .get_by_username_with_executor("reallystick", &mut *transaction)
        .await?
        .unwrap();

    let private_discussion_repo = PrivateDiscussionRepositoryImpl::new(pool.clone());
    let private_discussion_participation_repo =
        PrivateDiscussionParticipationRepositoryImpl::new(pool.clone());

    for user in users {
        let existing_discussion = private_discussion_repo
            .get_by_users_with_executor(user.id, reallystick_user.id, &mut *transaction)
            .await
            .map_err(|e| sqlx::Error::Configuration(Box::new(std::io::Error::other(e))))?;

        if existing_discussion.is_some() {
            continue;
        }

        let discussion = PrivateDiscussion {
            id: Uuid::new_v4(),
            created_at: now(),
        };

        private_discussion_repo
            .create_with_executor(&discussion, &mut *transaction)
            .await
            .map_err(|e| {
                sqlx::Error::Configuration(Box::new(std::io::Error::other(e.to_string())))
            })?;

        let discussion_participation_for_user = PrivateDiscussionParticipation {
            id: Uuid::new_v4(),
            user_id: user.id,
            discussion_id: discussion.id,
            color: "blue".to_string(),
            created_at: now(),
            has_blocked: false,
        };

        let discussion_participation_for_reallystick_user = PrivateDiscussionParticipation {
            id: Uuid::new_v4(),
            user_id: reallystick_user.id,
            discussion_id: discussion.id,
            color: "blue".to_string(),
            created_at: now(),
            has_blocked: false,
        };

        private_discussion_participation_repo
            .create_with_executor(&discussion_participation_for_user, &mut *transaction)
            .await
            .map_err(|e| {
                sqlx::Error::Configuration(Box::new(std::io::Error::other(e.to_string())))
            })?;

        private_discussion_participation_repo
            .create_with_executor(
                &discussion_participation_for_reallystick_user,
                &mut *transaction,
            )
            .await
            .map_err(|e| {
                sqlx::Error::Configuration(Box::new(std::io::Error::other(e.to_string())))
            })?;

        let mut args = FluentArgs::new();
        args.set("username", user.username);

        let translator = Translator::new();

        let private_message = PrivateMessage {
            id: Uuid::new_v4(),
            discussion_id: discussion.id,
            creator: reallystick_user.id,
            created_at: now(),
            updated_at: None,
            content: translator.translate(&user.locale, "welcome-private-message", Some(args)),
            creator_encrypted_session_key: "NOT_ENCRYPTED".to_string(),
            recipient_encrypted_session_key: "NOT_ENCRYPTED".to_string(),
            deleted: false,
            seen: false,
        };

        let private_message_repo = PrivateMessageRepositoryImpl::new(pool.clone());
        private_message_repo
            .create_with_executor(&private_message, &mut *transaction)
            .await
            .map_err(|e| {
                sqlx::Error::Configuration(Box::new(std::io::Error::other(e.to_string())))
            })?;
    }

    transaction.commit().await?;

    Ok(())
}

pub async fn remove_expired_user_tokens(pool: &PgPool) -> Result<(), sqlx::Error> {
    let mut transaction = match pool.begin().await {
        Ok(t) => t,
        Err(_) => panic!("Can't get a transaction."),
    };

    let token_repo = UserTokenRepositoryImpl::new(pool.clone());
    let result = token_repo
        .delete_expired_with_executor(&mut *transaction)
        .await?;

    info!("Deleted {} expired user tokens.", result.rows_affected());

    transaction.commit().await?;

    Ok(())
}
