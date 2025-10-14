use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};

use api::features::private_discussions::structs::{
    requests::private_discussion_participation::PrivateDiscussionParticipationUpdateRequest,
    responses::private_discussion_participation::PrivateDiscussionParticipationResponse,
};
use uuid::Uuid;

use crate::{
    auth::{login::user_logs_in, signup::user_signs_up},
    helpers::spawn_app,
    private_discussions::private_discussion::{
        user_creates_a_private_discussion, user_gets_private_discussions,
    },
    profile::profile::user_has_access_to_protected_route,
};

pub async fn user_updates_a_private_discussion_participation(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    color: &str,
    has_blocked: bool,
    discussion_id: Uuid,
) {
    let req = test::TestRequest::put()
        .uri(&format!(
            "/api/private-discussion-participations/{}",
            discussion_id
        ))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(PrivateDiscussionParticipationUpdateRequest {
            has_blocked,
            color: color.to_string(),
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: PrivateDiscussionParticipationResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "PRIVATE_DISCUSSION_PARTICIPATION_UPDATED");
}

#[tokio::test]
pub async fn user_can_update_a_private_discussion_participation() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;
    let thomas_id = user_has_access_to_protected_route(&app, &access_token)
        .await
        .id;

    let (access_token, _) = user_signs_up(&app, None).await;

    let private_discussions = user_gets_private_discussions(&app, &access_token).await;
    assert_eq!(private_discussions.len(), 1);

    let discussion_id =
        user_creates_a_private_discussion(&app, &access_token, thomas_id, "blue").await;

    let private_discussions = user_gets_private_discussions(&app, &access_token).await;
    assert_eq!(private_discussions.len(), 2);
    assert_eq!(private_discussions[1].has_blocked, Some(false));
    assert_eq!(private_discussions[1].color, Some("blue".to_string()));

    user_updates_a_private_discussion_participation(
        &app,
        &access_token,
        "yellow",
        true,
        discussion_id,
    )
    .await;

    let private_discussions = user_gets_private_discussions(&app, &access_token).await;
    assert_eq!(private_discussions.len(), 2);
    assert_eq!(private_discussions[1].has_blocked, Some(true));
    assert_eq!(private_discussions[1].color, Some("yellow".to_string()));
}
