use std::collections::HashMap;

use actix_http::{header, Request};
use actix_web::{
    body::MessageBody,
    dev::{Service, ServiceResponse},
    http::header::ContentType,
    test, Error,
};
use reallystick::features::habits::structs::{
    models::unit::UnitData,
    responses::unit::{UnitResponse, UnitsResponse},
};
use serde_json::json;
use uuid::Uuid;

use crate::{auth::login::user_logs_in, helpers::spawn_app};

pub async fn user_creates_a_unit(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Uuid {
    let req = test::TestRequest::post()
        .uri("/api/units/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "short_name": HashMap::from([("en", "h")]),
            "long_name": HashMap::from([("en", "hour")]),
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: UnitResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "UNIT_CREATED");
    assert!(response.unit.is_some());

    response.unit.unwrap().id
}

pub async fn user_updates_a_unit(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
    unit_id: Uuid,
) {
    let req = test::TestRequest::put()
        .uri(&format!("/api/units/{}", unit_id))
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .insert_header(ContentType::json())
        .set_json(&serde_json::json!({
            "short_name": HashMap::from([("en", "h"), ("fr", "h")]),
            "long_name": HashMap::from([("en", "hour"), ("fr", "heure")]),
        }))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: UnitResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "UNIT_UPDATED");
    assert!(response.unit.is_some());
    assert_eq!(
        response.unit.unwrap().short_name,
        json!(HashMap::from([("en", "h"), ("fr", "h")])).to_string()
    );
}

pub async fn user_gets_units(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    access_token: &str,
) -> Vec<UnitData> {
    let req = test::TestRequest::get()
        .uri("/api/units/")
        .insert_header((header::AUTHORIZATION, format!("Bearer {}", access_token)))
        .to_request();
    let response = test::call_service(&app, req).await;

    assert_eq!(200, response.status().as_u16());

    let body = test::read_body(response).await;
    let response: UnitsResponse = serde_json::from_slice(&body).unwrap();

    assert_eq!(response.code, "UNITS_FETCHED");
    response.units
}

#[tokio::test]
pub async fn admin_user_can_create_a_unit() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;

    let units = user_gets_units(&app, &access_token).await;
    assert!(units.is_empty());

    user_creates_a_unit(&app, &access_token).await;

    let units = user_gets_units(app, &access_token).await;
    assert!(!units.is_empty());
}

#[tokio::test]
pub async fn admin_user_can_update_a_unit() {
    let app = spawn_app().await;
    let (access_token, _) = user_logs_in(&app, "thomas", "").await;

    let unit_id = user_creates_a_unit(&app, &access_token).await;
    user_updates_a_unit(app, &access_token, unit_id).await;
}
