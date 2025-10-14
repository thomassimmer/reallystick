use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};

use api::features::private_discussions::structs::{
    models::private_discussion::PrivateDiscussionData,
    requests::private_discussion::PrivateDiscussionCreateRequest,
    responses::private_discussion::{PrivateDiscussionResponse, PrivateDiscussionsResponse},
};
use uuid::Uuid;

use crate::{
    auth::{login::user_logs_in, signup::user_signs_up},
    helpers::spawn_app,
    profile::profile::user_has_access_to_protected_route,
};

pub async fn user_creates_a_private_discussion(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    recipient: Uuid,
    color: &str,
) -> Uuid {
    let req = test::TestRequest::post()
        .uri("/api/private-discussions/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(PrivateDiscussionCreateRequest {
            recipient,
            color: color.to_string(),
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PrivateDiscussionResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PRIVATE_DISCUSSION_CREATED");
    response.discussion.unwrap().id
}

pub async fn user_gets_private_discussions(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<PrivateDiscussionData> {
    let req = test::TestRequest::get()
        .uri("/api/private-discussions/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PrivateDiscussionsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PRIVATE_DISCUSSIONS_FETCHED");
    response.discussions
}

#[tokio::test]
pub async fn user_can_create_private_discussion() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let thomas_id = user_has_access_to_protected_route(&app, &access_token)
        .await
        .id;

    let (access_token, _) = user_signs_up(&app, None).await;

    let private_discussions = user_gets_private_discussions(&app, &access_token).await;
    assert_eq!(private_discussions.len(), 1);

    user_creates_a_private_discussion(&app, &access_token, thomas_id, "blue").await;

    let private_discussions = user_gets_private_discussions(&app, &access_token).await;
    assert_eq!(private_discussions.len(), 2);
    assert_eq!(private_discussions[1].color, Some("blue".to_string()));
}
