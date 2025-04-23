use reallystick::{configuration::get_configuration, startup_notifications::Application};
use tracing::{error, info};
use tracing_subscriber::{EnvFilter, FmtSubscriber};

#[tokio::main]
async fn main() {
    FmtSubscriber::builder()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let configuration = get_configuration().expect("Failed to read configuration.");
    let application = Application::build(configuration.clone())
        .await
        .expect("Failed to build the app");

    info!(
        "🚀  Notification server started successfully at : http://{}:{}",
        configuration.application.host, configuration.application.port
    );

    if let Err(e) = application.run_until_stopped().await {
        error!("Server failed: {}", e);
    }
}
