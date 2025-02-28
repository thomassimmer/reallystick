use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use reallystick::features::profile::structs::{
    models::UserPublicData,
    requests::{GetUserPublicDataByIdRequest, GetUserPublicDataByUsernameRequest},
    responses::{UserPublicResponse, UsersResponse},
};
use uuid::Uuid;

use crate::{auth::signup::user_signs_up, helpers::spawn_app};

use super::profile::user_has_access_to_protected_route;

pub async fn user_gets_other_user_data_by_id(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    user_ids: Vec<Uuid>,
) -> Vec<UserPublicData> {
    let req = test::TestRequest::post()
        .uri("/api/users/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&GetUserPublicDataByIdRequest { user_ids })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: UsersResponse = serde_json::from_slice(&body).unwrap();

    response.users
}

pub async fn user_gets_other_user_data_by_username(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    username: &str,
) -> UserPublicData {
    let req = test::TestRequest::post()
        .uri("/api/users/by-username/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&GetUserPublicDataByUsernameRequest {
            username: username.to_string(),
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: UserPublicResponse = serde_json::from_slice(&body).unwrap();

    response.user
}

#[tokio::test]
pub async fn user_can_get_other_users_public_data() {
    let app = spawn_app().await;
    let (access_token, _) = user_signs_up(&app, None).await;

    let user_id = user_has_access_to_protected_route(&app, &access_token)
        .await
        .id;

    let users = user_gets_other_user_data_by_id(&app, &access_token, vec![user_id]).await;
    assert_eq!(users.len(), 1);

    let (access_token, _) = user_signs_up(&app, Some("testusername2")).await;

    let user_id2 = user_has_access_to_protected_route(&app, &access_token)
        .await
        .id;

    let users = user_gets_other_user_data_by_id(&app, &access_token, vec![user_id, user_id2]).await;
    assert_eq!(users.len(), 2);

    user_gets_other_user_data_by_username(&app, &access_token, "testusername").await;

    let req = test::TestRequest::post()
        .uri("/api/users/by-username/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&GetUserPublicDataByUsernameRequest {
            username: "username_not_existing".to_string(),
        })
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(404, response.status().as_u16());
}
