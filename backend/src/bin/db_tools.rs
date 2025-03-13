use clap::Parser;
use reallystick::configuration::get_configuration;
use reallystick::core::helpers::startup::{populate_database, reset_database};
use reallystick::startup::get_connection_pool;
use tracing::error;

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
            println!("Resetting the database...");
            if let Err(e) = reset_database(&pool).await {
                error!("Failed to reset the database: {}", e);
            } else {
                println!("Database successfully reset.");
            }
        }
        "populate" => {
            println!("Populating the database...");
            if let Err(e) = populate_database(&pool).await {
                error!("Failed to populate the database: {}", e);
            } else {
                println!("Database successfully populated.");
            }
        }
        _ => error!("Unknown action: {}", action),
    }
}
