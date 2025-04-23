use clap::Parser;
use reallystick::configuration::get_configuration;
use reallystick::core::helpers::startup::{
    create_missing_discussions_with_reallystick_user, populate_database,
    remove_expired_user_tokens, remove_users_marked_as_deleted_after_3_days, reset_database,
};
use reallystick::startup::get_connection_pool;
use tracing::{error, info};
use tracing_subscriber::{EnvFilter, FmtSubscriber};

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Args {
    action: String,
}

#[tokio::main]
async fn main() {
    FmtSubscriber::builder()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let args = Args::parse();
    let action = args.action;
    let configuration = get_configuration().expect("Failed to read configuration.");
    let pool = get_connection_pool(&configuration.database);

    match action.as_str() {
        "reset" => {
            info!("Resetting the database...");
            if let Err(e) = reset_database(&pool).await {
                error!("Failed to reset the database: {}", e);
            } else {
                info!("Database successfully reset.");
            }
        }
        "populate" => {
            info!("Populating the database...");
            if let Err(e) = populate_database(&pool).await {
                error!("Failed to populate the database: {}", e);
            } else {
                info!("Database successfully populated.");
            }
        }
        "create_missing_discussions_with_reallystick_user" => {
            if let Err(e) = create_missing_discussions_with_reallystick_user(&pool).await {
                error!(
                    "Failed to create missing discussions with reallystick user: {}",
                    e
                );
            } else {
                info!("Success !");
            }
        }
        "remove_users_marked_as_deleted_after_3_days" => {
            if let Err(e) = remove_users_marked_as_deleted_after_3_days(&pool).await {
                error!(
                    "Failed to remove users marked as deleted after 3 days: {}",
                    e
                );
            }
        }
        "delete_expired_tokens" => {
            if let Err(e) = remove_expired_user_tokens(&pool).await {
                error!("Failed to delete expired tokens: {}", e);
            }
        }
        _ => error!("Unknown action: {}", action),
    }
}
