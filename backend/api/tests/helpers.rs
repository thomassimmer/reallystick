use std::sync::Arc;

use actix_http::Request;
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    test::init_service,
    Error,
};
use api::{
    configuration::get_configuration,
    core::helpers::translation::Translator,
    features::profile::{helpers::profile::create_user, structs::models::User},
    startup::create_app,
};
use api::{
    core::helpers::mock_now::now,
    features::{
        auth::structs::models::TokenCache,
        challenges::structs::models::challenge_statistics::ChallengeStatisticsCache,
        habits::structs::models::habit_statistics::HabitStatisticsCache,
        profile::structs::models::UserPublicDataCache,
    },
};
use argon2::PasswordHasher;
use argon2::{password_hash::SaltString, Argon2};
use rand::rngs::OsRng;
use sqlx::{Executor, PgPool};
use tracing::error;
use uuid::Uuid;

pub async fn spawn_app(
    pool: PgPool,
) -> impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error> {
    // Randomise configuration to ensure test isolation
    let configuration = {
        let mut c = get_configuration().expect("Failed to read configuration.");
        // Use a different database for each test case
        c.database.database_name = Uuid::new_v4().to_string();
        // Use a random OS port
        c.application.port = 0;
        c
    };

    let habit_statistics_cache = HabitStatisticsCache::default();
    let challenge_statistics_cache = ChallengeStatisticsCache::default();
    let token_cache = TokenCache::default();
    let user_public_data_cache = UserPublicDataCache::default();
    let redis_client = redis::Client::open("redis://redis:6379").unwrap();
    let translator = Arc::new(Translator::new());

    configure_database(&pool).await;
    let secret = configuration.application.secret;

    init_service(create_app(
        pool.clone(),
        secret.clone(),
        habit_statistics_cache,
        challenge_statistics_cache,
        token_cache,
        user_public_data_cache,
        redis_client,
        translator,
    ))
    .await
}

pub async fn configure_database(pool: &PgPool) {
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
        otp_verified: false,
        otp_base32: None,
        otp_auth_url: None,
        created_at: now(),
        updated_at: now(),
        deleted_at: None,
        is_deleted: false,
        public_key: None,
        private_key_encrypted: None,
        salt_used_to_derive_key_from_password: None,
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
        notifications_user_joined_your_challenge_enabled: true,
    };

    let reallystick = User {
        id: Uuid::new_v4(),
        username: "reallystick".to_string(),
        password: password_hash,
        locale: "fr".to_string(),
        theme: "light".to_string(),
        timezone: "America/New_York".to_string(),
        is_admin: true,
        otp_verified: false,
        otp_base32: None,
        otp_auth_url: None,
        created_at: now(),
        updated_at: now(),
        deleted_at: None,
        is_deleted: false,
        public_key: None,
        private_key_encrypted: None,
        salt_used_to_derive_key_from_password: None,
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
        notifications_user_joined_your_challenge_enabled: true,
    };

    let result = create_user(pool, thomas.clone()).await;

    if let Err(e) = result {
        error!("{}", e);
    }

    let result = create_user(pool, reallystick.clone()).await;

    if let Err(e) = result {
        error!("{}", e);
    }

    pool.execute(r#"DELETE from units;"#)
        .await
        .expect("Failed to create database.");
}
