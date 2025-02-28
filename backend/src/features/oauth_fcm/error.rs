/// Enum representing the possible errors that can occur in the Firebase Cloud
/// Messaging (FCM) service.
///
/// This includes network errors related to OAuth and FCM requests,
/// serialization errors, JWT encoding errors, and IO errors.
///
/// Each variant contains a detailed error message for easy debugging.
#[derive(thiserror::Error, Debug)]
pub enum FcmError {
    #[error("Error while sending OAuth request: {0}")]
    OAuthNetworkError(NetworkError),

    #[error("Error while sending FCM: {0}")]
    FcmNetworkError(NetworkError),

    #[error("FCM payload neither contains data or notification payload")]
    FcmInvalidPayloadError,

    #[error("Failed to serialize data: {0}")]
    SerializationError(#[from] serde_json::Error),

    #[error("Failed to encode JWT: {0}")]
    JwtEncodeError(#[from] jsonwebtoken::errors::Error),

    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),
}

/// Enum representing the possible network errors that can occur when sending
/// requests to the OAuth or FCM server.
#[derive(thiserror::Error, Debug)]
pub enum NetworkError {
    #[error("Failed to send request: {0}")]
    SendRequestError(reqwest::Error),

    #[error("Failed to evaluate server response: {0}")]
    ResponseError(reqwest::Error),

    #[error("Server returned status: {0}, opt text:")]
    ServerError(u16, Option<String>),
}

pub trait ResultMapError<T> {
    fn map_oauth_err(self) -> Result<T, FcmError>;

    fn map_fcm_err(self) -> Result<T, FcmError>;
}

impl<T, E> ResultMapError<T> for Result<T, E>
where
    E: Into<NetworkError>,
{
    fn map_oauth_err(self) -> Result<T, FcmError> {
        match self {
            Ok(t) => Ok(t),
            Err(e) => Err(FcmError::OAuthNetworkError(e.into())),
        }
    }

    fn map_fcm_err(self) -> Result<T, FcmError> {
        match self {
            Ok(t) => Ok(t),
            Err(e) => Err(FcmError::FcmNetworkError(e.into())),
        }
    }
}
