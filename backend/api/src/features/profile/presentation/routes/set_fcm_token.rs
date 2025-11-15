// Legacy route - now uses clean architecture
// Re-export from auth presentation layer for backward compatibility
pub use crate::features::auth::presentation::routes::set_fcm_token::set_fcm_token;
