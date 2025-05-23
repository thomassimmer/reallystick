// Inspired by : https://github.com/actix/actix-web/issues/1147

use std::fs::File;
use std::net::TcpListener;
use std::time::Duration;

use crate::configuration::{DatabaseSettings, Settings};
use crate::core::helpers::translation::Translator;
use crate::core::middlewares::token_validator::TokenValidator;
use crate::core::routes::health_check::health_check;

use crate::core::routes::statistics::statistics;
use crate::features::auth::structs::models::TokenCache;
use crate::features::notifications::helpers::redis_handler::handle_redis_messages;
use crate::features::notifications::helpers::reminders::send_reminder_notifications;
use crate::features::oauth_fcm::token_manager::create_shared_token_manager;
use crate::features::private_discussions::routes::websocket::broadcast_ws;
use crate::features::private_discussions::structs::models::channels_data::ChannelsData;
use crate::features::private_discussions::structs::models::users_data::UsersData;

use actix_cors::Cors;
use actix_http::header::HeaderName;
use actix_web::body::MessageBody;
use actix_web::dev::{Server, ServiceFactory, ServiceRequest, ServiceResponse};
use actix_web::http::header;
use actix_web::middleware::Logger;
use actix_web::{web, App, Error, HttpServer};

use redis::Client;
use sqlx::postgres::PgPoolOptions;
use sqlx::{Error as SqlxError, PgPool, Pool, Postgres};
use tokio::task;
use tokio::time::interval;

pub async fn run(listener: TcpListener, configuration: Settings) -> Result<Server, std::io::Error> {
    let connection_pool = get_connection_pool(&configuration.database).await.unwrap();
    let secret = configuration.application.secret;

    let token_cache = TokenCache::default();
    let channels_data = ChannelsData::default();
    let users_data = UsersData::default();
    let shared_token_manager = create_shared_token_manager(File::open(
        "reallystick-d807d-firebase-adminsdk-fbsvc-50c4957a9f.json",
    )?)
    .expect("Could not find credentials.json");

    let redis_client = Client::open("redis://redis:6379").unwrap();

    let connection_pool_for_redis_handler = connection_pool.clone();
    let channels_data_for_redis_handler = channels_data.clone();
    let users_data_for_redis_handler = users_data.clone();
    let shared_token_manager_for_redis_handler = shared_token_manager.clone();

    let connection_pool_for_reminder_handler = connection_pool.clone();
    let users_data_for_reminder_handler = users_data.clone();
    let shared_token_manager_for_reminder_handler = shared_token_manager.clone();

    task::spawn(async move {
        handle_redis_messages(
            redis_client,
            connection_pool_for_redis_handler,
            channels_data_for_redis_handler,
            users_data_for_redis_handler,
            shared_token_manager_for_redis_handler,
        )
        .await;
    });

    task::spawn(async move {
        let mut interval = interval(Duration::from_secs(60));
        let translator = Translator::new();

        loop {
            interval.tick().await;

            let connection_pool_for_reminder_handler = connection_pool_for_reminder_handler.clone();
            let users_data_for_reminder_handler = users_data_for_reminder_handler.clone();
            let shared_token_manager_for_reminder_handler =
                shared_token_manager_for_reminder_handler.clone();

            send_reminder_notifications(
                connection_pool_for_reminder_handler,
                users_data_for_reminder_handler,
                shared_token_manager_for_reminder_handler,
                &translator,
            )
            .await;
        }
    });

    let server = HttpServer::new(move || {
        create_app(
            connection_pool.clone(),
            secret.clone(),
            token_cache.clone(),
            channels_data.clone(),
            users_data.clone(),
        )
    })
    .listen(listener)?
    .run();

    Ok(server)
}

pub fn create_app(
    connection_pool: Pool<Postgres>,
    secret: String,
    token_cache: TokenCache,
    channels_data: ChannelsData,
    users_data: UsersData,
) -> App<
    impl ServiceFactory<
        ServiceRequest,
        Config = (),
        Response = ServiceResponse<impl MessageBody>,
        Error = Error,
        InitError = (),
    >,
> {
    let cors = Cors::default()
        .allowed_origin_fn(|origin, _req_head| origin.as_bytes().starts_with(b"http://localhost:"))
        .allowed_origin("https://reallystick.com")
        .allowed_methods(vec!["GET", "POST", "PUT", "DELETE", "OPTIONS"])
        .allowed_headers(vec![
            header::CONTENT_TYPE,
            header::AUTHORIZATION,
            header::ACCEPT,
            HeaderName::from_static("x-user-agent"),
        ])
        .supports_credentials();

    App::new()
        .service(
            web::scope("/api")
                .service(health_check)
                .service(broadcast_ws)
                .service(web::scope("").wrap(TokenValidator {}).service(statistics)),
        )
        .wrap(cors)
        .wrap(Logger::default())
        .app_data(web::Data::new(connection_pool))
        .app_data(web::Data::new(secret))
        .app_data(web::Data::new(token_cache))
        .app_data(web::Data::new(channels_data))
        .app_data(web::Data::new(users_data))
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
        let server = run(listener, configuration).await.unwrap();

        Ok(Self { port, server })
    }

    pub fn port(&self) -> u16 {
        self.port
    }

    pub async fn run_until_stopped(self) -> Result<(), std::io::Error> {
        self.server.await
    }
}

pub async fn get_connection_pool(configuration: &DatabaseSettings) -> Result<PgPool, SqlxError> {
    PgPoolOptions::new()
        .max_connections(50)
        .acquire_timeout(Duration::from_secs(5))
        .connect_with(configuration.with_db())
        .await
}
