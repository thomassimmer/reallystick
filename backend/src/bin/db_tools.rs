use clap::Parser;
use reallystick::configuration::get_configuration;
use reallystick::core::helpers::startup::{
    create_missing_discussions_with_reallystick_user, populate_database, reset_database,
};
use reallystick::startup::get_connection_pool;
use tracing::{error, info};

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Args {
    action: String,
}

#[tokio::main]
async fn main() {
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
        _ => error!("Unknown action: {}", action),
    }
}
