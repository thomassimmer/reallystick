use actix_http::Request;
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    test::init_service,
    Error,
};
use argon2::PasswordHasher;
use argon2::{password_hash::SaltString, Argon2};
use rand::rngs::OsRng;
use reallystick::core::helpers::mock_now::now;
use reallystick::{
    configuration::{get_configuration, DatabaseSettings},
    features::profile::{helpers::user::create_user, structs::models::User},
    startup::create_app,
};
use sqlx::{migrate, Connection, Executor, PgConnection, PgPool};
use uuid::Uuid;

pub async fn spawn_app(
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

    configure_database(&configuration.database).await;
    init_service(create_app(&configuration)).await
}

async fn configure_database(config: &DatabaseSettings) {
    // Create database
    let mut connection = PgConnection::connect_with(&config.without_db())
        .await
        .expect("Failed to connect to Postgres");
    connection
        .execute(&*format!(r#"CREATE DATABASE "{}";"#, config.database_name))
        .await
        .expect("Failed to create database.");

    // Migrate database
    let connection_pool = PgPool::connect_with(config.with_db())
        .await
        .expect("Failed to connect to Postgres.");
    migrate!("./migrations")
        .run(&connection_pool)
        .await
        .expect("Failed to migrate the database");

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

    let mut connection = PgConnection::connect_with(&config.with_db())
        .await
        .expect("Failed to connect to Postgres");
    let result = create_user(&mut connection, new_user.clone()).await;

    connection
        .execute(r#"DELETE from units;"#)
        .await
        .expect("Failed to create database.");

    if let Err(e) = result {
        eprintln!("{}", e);
    }
}
