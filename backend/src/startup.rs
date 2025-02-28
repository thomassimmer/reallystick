// Inspired by : https://github.com/actix/actix-web/issues/1147

use std::net::TcpListener;

use crate::configuration::{DatabaseSettings, Settings};
use crate::core::middlewares::token_validator::TokenValidator;
use crate::core::routes::health_check::health_check;
use crate::features::auth::routes::disable_otp::disable;
use crate::features::auth::routes::generate_otp::generate;
use crate::features::auth::routes::log_user_in::log_user_in;
use crate::features::auth::routes::recover_account_using_2fa::recover_account_using_2fa;
use crate::features::auth::routes::recover_account_using_password::recover_account_using_password;
use crate::features::auth::routes::recover_account_without_2fa_enabled::recover_account_without_2fa_enabled;
use crate::features::auth::routes::validate_otp::validate;
use crate::features::auth::routes::verify_otp::verify;

use crate::features::auth::routes::signup::register_user;
use crate::features::auth::routes::token::refresh_token;
use crate::features::challenges::routes::create_challenge::create_challenge;
use crate::features::challenges::routes::create_challenge_daily_tracking::create_challenge_daily_tracking;
use crate::features::challenges::routes::create_challenge_participation::create_challenge_participation;
use crate::features::challenges::routes::delete_challenge::delete_challenge;
use crate::features::challenges::routes::delete_challenge_daily_tracking::delete_challenge_daily_tracking;
use crate::features::challenges::routes::delete_challenge_participation::delete_challenge_participation;
use crate::features::challenges::routes::get_challenge::get_challenge;
use crate::features::challenges::routes::get_challenge_daily_trackings::get_challenge_daily_trackings;
use crate::features::challenges::routes::get_challenge_participations::get_challenge_participations;
use crate::features::challenges::routes::get_challenge_statistics::get_challenge_statistics;
use crate::features::challenges::routes::get_challenges::get_challenges;
use crate::features::challenges::routes::get_challenges_daily_trackings::get_challenges_daily_trackings;
use crate::features::challenges::routes::update_challenge::update_challenge;
use crate::features::challenges::routes::update_challenge_daily_tracking::update_challenge_daily_tracking;
use crate::features::challenges::routes::update_challenge_participation::update_challenge_participation;
use crate::features::challenges::structs::models::challenge_statistics::ChallengeStatisticsCache;
use crate::features::habits::routes::create_habit::create_habit;
use crate::features::habits::routes::create_habit_category::create_habit_category;
use crate::features::habits::routes::create_habit_daily_tracking::create_habit_daily_tracking;
use crate::features::habits::routes::create_habit_participation::create_habit_participation;
use crate::features::habits::routes::create_unit::create_unit;
use crate::features::habits::routes::delete_habit::delete_habit;
use crate::features::habits::routes::delete_habit_category::delete_habit_category;
use crate::features::habits::routes::delete_habit_daily_tracking::delete_habit_daily_tracking;
use crate::features::habits::routes::delete_habit_participation::delete_habit_participation;
use crate::features::habits::routes::get_habit::get_habit;
use crate::features::habits::routes::get_habit_categories::get_habit_categories;
use crate::features::habits::routes::get_habit_daily_trackings::get_habit_daily_trackings;
use crate::features::habits::routes::get_habit_participations::get_habit_participations;
use crate::features::habits::routes::get_habit_statistics::get_habit_statistics;
use crate::features::habits::routes::get_habits::get_habits;
use crate::features::habits::routes::get_units::get_units;
use crate::features::habits::routes::merge_habits::merge_habits;
use crate::features::habits::routes::update_habit::update_habit;
use crate::features::habits::routes::update_habit_category::update_habit_category;
use crate::features::habits::routes::update_habit_daily_tracking::update_habit_daily_tracking;
use crate::features::habits::routes::update_habit_participation::update_habit_participation;
use crate::features::habits::routes::update_unit::update_unit;
use crate::features::habits::structs::models::habit_statistics::HabitStatisticsCache;
use crate::features::profile::routes::delete_account::delete_account;
use crate::features::profile::routes::get_profile_information::get_profile_information;
use crate::features::profile::routes::is_otp_enabled::is_otp_enabled;
use crate::features::profile::routes::post_profile_information::post_profile_information;

use crate::features::profile::routes::set_password::set_password;
use crate::features::profile::routes::update_password::update_password;
use actix_cors::Cors;
use actix_web::body::MessageBody;
use actix_web::dev::{Server, ServiceFactory, ServiceRequest, ServiceResponse};
use actix_web::http::header;
use actix_web::middleware::Logger;
use actix_web::{web, App, Error, HttpServer};
use sqlx::postgres::PgPoolOptions;
use sqlx::PgPool;

pub fn run(listener: TcpListener, configuration: Settings) -> Result<Server, std::io::Error> {
    let server = HttpServer::new(move || create_app(&configuration))
        .listen(listener)?
        .run();

    Ok(server)
}

pub fn create_app(
    configuration: &Settings,
) -> App<
    impl ServiceFactory<
        ServiceRequest,
        Config = (),
        Response = ServiceResponse<impl MessageBody>,
        Error = Error,
        InitError = (),
    >,
> {
    let connection_pool = get_connection_pool(&configuration.database);
    let secret = &configuration.application.secret;

    let cors = Cors::default()
        .allowed_origin_fn(|origin, _req_head| origin.as_bytes().starts_with(b"http://localhost:"))
        .allowed_origin("https://reallystick.com")
        .allowed_methods(vec!["GET", "POST", "PUT", "DELETE", "OPTIONS"])
        .allowed_headers(vec![
            header::CONTENT_TYPE,
            header::AUTHORIZATION,
            header::ACCEPT,
        ])
        .supports_credentials();

    let habit_cache = HabitStatisticsCache::new();
    let challenge_cache = ChallengeStatisticsCache::new();

    App::new()
        .service(
            web::scope("/api")
                .service(health_check)
                .service(
                    web::scope("/auth")
                        .service(register_user)
                        .service(log_user_in)
                        .service(recover_account_without_2fa_enabled)
                        .service(recover_account_using_password)
                        .service(recover_account_using_2fa)
                        .service(refresh_token)
                        .service(
                            web::scope("/otp")
                                // Scope without middleware applied to routes that don't need it
                                .service(validate)
                                // Nested scope with middleware for protected routes
                                .service(
                                    web::scope("")
                                        .wrap(TokenValidator::new(
                                            secret.to_string(),
                                            connection_pool.clone(),
                                        ))
                                        .service(generate)
                                        .service(verify)
                                        .service(disable),
                                ),
                        ),
                )
                .service(
                    web::scope("/users").service(is_otp_enabled).service(
                        web::scope("")
                            .wrap(TokenValidator::new(
                                secret.to_string(),
                                connection_pool.clone(),
                            ))
                            .service(get_profile_information)
                            .service(post_profile_information)
                            .service(set_password)
                            .service(delete_account)
                            .service(update_password),
                    ),
                )
                .service(
                    web::scope("/habits").service(
                        web::scope("")
                            .wrap(TokenValidator::new(
                                secret.to_string(),
                                connection_pool.clone(),
                            ))
                            .service(get_habit)
                            .service(get_habits)
                            .service(update_habit)
                            .service(create_habit)
                            .service(delete_habit)
                            .service(merge_habits),
                    ),
                )
                .service(
                    web::scope("/habit-statistics").service(
                        web::scope("")
                            .wrap(TokenValidator::new(
                                secret.to_string(),
                                connection_pool.clone(),
                            ))
                            .service(get_habit_statistics),
                    ),
                )
                .service(
                    web::scope("/habit-categories").service(
                        web::scope("")
                            .wrap(TokenValidator::new(
                                secret.to_string(),
                                connection_pool.clone(),
                            ))
                            .service(get_habit_categories)
                            .service(update_habit_category)
                            .service(create_habit_category)
                            .service(delete_habit_category),
                    ),
                )
                .service(
                    web::scope("/habit-daily-trackings").service(
                        web::scope("")
                            .wrap(TokenValidator::new(
                                secret.to_string(),
                                connection_pool.clone(),
                            ))
                            .service(get_habit_daily_trackings)
                            .service(update_habit_daily_tracking)
                            .service(create_habit_daily_tracking)
                            .service(delete_habit_daily_tracking),
                    ),
                )
                .service(
                    web::scope("/habit-participations").service(
                        web::scope("")
                            .wrap(TokenValidator::new(
                                secret.to_string(),
                                connection_pool.clone(),
                            ))
                            .service(get_habit_participations)
                            .service(update_habit_participation)
                            .service(create_habit_participation)
                            .service(delete_habit_participation),
                    ),
                )
                .service(
                    web::scope("/units").service(
                        web::scope("")
                            .wrap(TokenValidator::new(
                                secret.to_string(),
                                connection_pool.clone(),
                            ))
                            .service(get_units)
                            .service(update_unit)
                            .service(create_unit),
                    ),
                )
                .service(
                    web::scope("/challenges").service(
                        web::scope("")
                            .wrap(TokenValidator::new(
                                secret.to_string(),
                                connection_pool.clone(),
                            ))
                            .service(get_challenges)
                            .service(get_challenge)
                            .service(update_challenge)
                            .service(create_challenge)
                            .service(delete_challenge),
                    ),
                )
                .service(
                    web::scope("/challenge-statistics").service(
                        web::scope("")
                            .wrap(TokenValidator::new(
                                secret.to_string(),
                                connection_pool.clone(),
                            ))
                            .service(get_challenge_statistics),
                    ),
                )
                .service(
                    web::scope("/challenge-daily-trackings").service(
                        web::scope("")
                            .wrap(TokenValidator::new(
                                secret.to_string(),
                                connection_pool.clone(),
                            ))
                            .service(get_challenge_daily_trackings)
                            .service(get_challenges_daily_trackings)
                            .service(update_challenge_daily_tracking)
                            .service(create_challenge_daily_tracking)
                            .service(delete_challenge_daily_tracking),
                    ),
                )
                .service(
                    web::scope("/challenge-participations").service(
                        web::scope("")
                            .wrap(TokenValidator::new(
                                secret.to_string(),
                                connection_pool.clone(),
                            ))
                            .service(get_challenge_participations)
                            .service(update_challenge_participation)
                            .service(create_challenge_participation)
                            .service(delete_challenge_participation),
                    ),
                ),
        )
        .wrap(cors)
        .wrap(Logger::default())
        .app_data(web::Data::new(connection_pool.clone()))
        .app_data(web::Data::new(secret.clone()))
        .app_data(web::Data::new(habit_cache))
        .app_data(web::Data::new(challenge_cache))
}

pub struct Application {
    port: u16,
    server: Server,
}

impl Application {
    pub async fn build(configuration: Settings) -> Result<Self, std::io::Error> {
        let address = format!(
            "{}:{}",
            configuration.application.host, configuration.application.port
        );
        let listener = TcpListener::bind(address)?;
        let port = listener.local_addr().unwrap().port();
        let server = run(listener, configuration).unwrap();

        Ok(Self { port, server })
    }

    pub fn port(&self) -> u16 {
        self.port
    }

    pub async fn run_until_stopped(self) -> Result<(), std::io::Error> {
        self.server.await
    }
}

pub fn get_connection_pool(configuration: &DatabaseSettings) -> PgPool {
    PgPoolOptions::new().connect_lazy_with(configuration.with_db())
}
