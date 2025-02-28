use serde::Serialize;
use serde_json::json;
use tracing::debug;
use tracing::error;
use tracing::info;
use tracing::instrument;

use super::error::NetworkError;
use super::error::ResultMapError;
use super::error::FcmError;
use super::token_manager::SharedTokenManager;

/// A wrapper for Firebase Cloud Messaging (FCM) notifications.
pub struct FcmNotification {
    pub title: String,
    pub body: String,
}

/// Sends a Firebase Cloud Messaging (FCM) message.
///
/// This function sends an FCM message to the device with the provided device
/// token. You can provide either a data payload or a notification payload, or
/// both. It uses the provided `SharedTokenManager` to handle OAuth tokens.
///
/// # Arguments
///
/// * `device_token` - The device token to send the notification to.
/// * `notification` - An optional `FcmNotification` containing the title and
///   body of the notification.
/// * `data_payload` - Optional data represented as a Map. This can be any type
///   that implements the `Serialize` trait.
/// * `token_manager` - A `SharedTokenManager` to handle OAuth tokens.
/// * `project_id` - The ID of the Firebase project, where the device token is
///   registered.
///
/// # Errors
///
/// This function will return an error if the FCM message could not be sent.
///
/// # Example
///
/// ```rust no_run
/// use std::fs::File;
///
/// use oauth_fcm::{create_shared_token_manager, send_fcm_message, SharedTokenManager};
///
/// # tokio_test::block_on(async {
/// let device_token = "device_token";
/// let data = serde_json::json!({
///    "key": "value"
/// });
/// let notification = oauth_fcm::FcmNotification {
///    title: "Test Title".to_string(),
///   body: "Test Body".to_string(),
/// };
/// let token_manager = create_shared_token_manager(File::open("path_to_google_credentials.json").expect("Failed to open file")).expect("Failed to create SharedTokenManager");
/// let project_id = "project_id";
/// send_fcm_message(device_token, Some(notification), Some(data), &token_manager, project_id)
///     .await
///     .expect("Error while sending FCM message");
///
/// # });
/// ```
#[instrument(level = "info", skip(data_payload, notification, token_manager))]
pub async fn send_fcm_message<T: Serialize>(
    device_token: &str,
    notification: Option<FcmNotification>,
    data_payload: Option<T>,
    token_manager: &SharedTokenManager,
    project_id: &str,
) -> Result<(), FcmError> {
    info!("Sending FCM message to device: {}", device_token);
    let url = format!("https://fcm.googleapis.com/v1/projects/{project_id}/messages:send");

    send_fcm_message_with_url(
        device_token,
        notification,
        data_payload,
        token_manager,
        &url,
    )
    .await
}

/// Sends a Firebase Cloud Messaging (FCM) message to a specific URL.
///
/// This function behaves exactly as `send_fcm`, but allows specifying a custom
/// FCM URL.
///
/// Normally, you would use `send_fcm` instead of this function. This is only
/// useful for testing, such as for mocking the FCM URL.
#[instrument(level = "debug", skip(data_payload, notification, token_manager))]
pub async fn send_fcm_message_with_url<T: Serialize>(
    device_token: &str,
    notification: Option<FcmNotification>,
    data_payload: Option<T>,
    token_manager: &SharedTokenManager,
    fcm_url: &str,
) -> Result<(), FcmError> {
    let access_token = {
        let mut token_manager_guard = token_manager.lock().await;
        token_manager_guard.get_token().await?
    };

    let client = reqwest::Client::new();

    let payload = create_payload(device_token, notification, data_payload)?;

    debug!("Requesting access token");

    let res = client
        .post(fcm_url)
        .bearer_auth(access_token)
        .json(&payload)
        .send()
        .await
        .map_err(NetworkError::SendRequestError)
        .map_fcm_err()?;

    if res.status().is_success() {
        debug!("FCM message sent successfully");
        Ok(())
    } else {
        let status = res.status().as_u16();
        let text = res
            .text()
            .await
            .map_err(NetworkError::ResponseError)
            .map_fcm_err()?;
        error!(
            "FCM message send successfully, but server returned an error. Status: {}, Response: {}",
            status, text
        );
        Err(NetworkError::ServerError(status, Some(text))).map_fcm_err()
    }
}

fn create_payload<T: Serialize>(
    device_token: &str,
    notification: Option<FcmNotification>,
    data_payload: Option<T>,
) -> Result<serde_json::Value, FcmError> {
    let payload = match (notification, data_payload) {
        (Some(notification), Some(data_payload)) => {
            let data = serde_json::to_value(data_payload).map_err(FcmError::SerializationError)?;
            json!({
                "message": {
                    "token": device_token,
                    "notification": {
                        "title": notification.title,
                        "body": notification.body
                    },
                    "data": data
                }
            })
        }
        (None, Some(data_payload)) => {
            let data = serde_json::to_value(data_payload).map_err(FcmError::SerializationError)?;
            json!({
                "message": {
                    "token": device_token,
                    "data": data
                }
            })
        }
        (Some(notification), None) => json!({
            "message": {
                "token": device_token,
                "notification": {
                    "title": notification.title,
                    "body": notification.body
                }
            }
        }),
        _ => return Err(FcmError::FcmInvalidPayloadError),
    };

    Ok(payload)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_create_payload_with_notification_and_data() {
        let device_token = "test_device_token";
        let notification = Some(FcmNotification {
            title: "Test Title".to_string(),
            body: "Test Body".to_string(),
        });
        let data_payload = Some(json!({
            "key": "value"
        }));

        let payload = create_payload(device_token, notification, data_payload).unwrap();
        assert_eq!(payload["message"]["token"], device_token);
        assert_eq!(payload["message"]["notification"]["title"], "Test Title");
        assert_eq!(payload["message"]["notification"]["body"], "Test Body");
        assert_eq!(payload["message"]["data"]["key"], "value");
    }

    #[tokio::test]
    async fn test_create_payload_with_only_notification() {
        let device_token = "test_device_token";
        let notification = Some(FcmNotification {
            title: "Test Title".to_string(),
            body: "Test Body".to_string(),
        });
        let data_payload: Option<serde_json::Value> = None;

        let payload = create_payload(device_token, notification, data_payload).unwrap();
        assert_eq!(payload["message"]["token"], device_token);
        assert_eq!(payload["message"]["notification"]["title"], "Test Title");
        assert_eq!(payload["message"]["notification"]["body"], "Test Body");
        assert!(payload["message"]["data"].is_null());
    }

    #[tokio::test]
    async fn test_create_payload_with_only_data() {
        let device_token = "test_device_token";
        let notification: Option<FcmNotification> = None;
        let data_payload = Some(json!({
            "key": "value"
        }));

        let payload = create_payload(device_token, notification, data_payload).unwrap();
        assert_eq!(payload["message"]["token"], device_token);
        assert!(payload["message"]["notification"].is_null());
        assert_eq!(payload["message"]["data"]["key"], "value");
    }

    #[derive(serde::Serialize)]
    struct TestData {
        key1: String,
        key2: String,
    }

    #[tokio::test]
    async fn test_create_payload_with_only_struct_data() {
        let device_token = "test_device_token";
        let notification: Option<FcmNotification> = None;
        let data_payload = TestData {
            key1: "value1".to_string(),
            key2: "value2".to_string(),
        };

        let payload = create_payload(device_token, notification, Some(data_payload)).unwrap();
        assert_eq!(payload["message"]["token"], device_token);
        assert!(payload["message"]["notification"].is_null());
        assert_eq!(payload["message"]["data"]["key1"], "value1");
        assert_eq!(payload["message"]["data"]["key2"], "value2");
    }

    #[tokio::test]
    async fn test_create_payload_with_no_notification_and_no_data() {
        let device_token = "test_device_token";
        let notification: Option<FcmNotification> = None;
        let data_payload: Option<serde_json::Value> = None;

        let payload = create_payload(device_token, notification, data_payload);
        assert!(payload.is_err());
    }
}
