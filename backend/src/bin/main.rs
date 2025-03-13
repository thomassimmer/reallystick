use reallystick::{configuration::get_configuration, startup::Application};
use tracing::{info, error};
use tracing_subscriber::FmtSubscriber;

#[tokio::main]
async fn main() {
    let subscriber = FmtSubscriber::builder()
        .with_max_level(tracing::Level::INFO)
        .finish();

    tracing::subscriber::set_global_default(subscriber).expect("setting default subscriber failed");

    let configuration = get_configuration().expect("Failed to read configuration.");
    let application = Application::build(configuration.clone())
        .await
        .expect("Failed to build the app");

    info!(
        "🚀  Server started successfully at : http://{}:{}",
        configuration.application.host, configuration.application.port
    );

    if let Err(e) = application.run_until_stopped().await {
        error!("Server failed: {}", e);
    }
}
