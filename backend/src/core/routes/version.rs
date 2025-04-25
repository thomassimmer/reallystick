use std::collections::HashMap;

use actix_web::{get, web::Query, HttpResponse, Responder};
use serde::Serialize;

#[derive(Serialize)]
struct VersionInfo {
    min_version: &'static str,
    latest_version: &'static str,
    update_required: bool,
    changelog: &'static str,
    store_url: StoreUrls,
}

#[derive(Serialize)]
struct StoreUrls {
    android: &'static str,
    ios: &'static str,
}

#[get("/version")]
async fn version_check(query: Query<HashMap<String, String>>) -> impl Responder {
    let _current_version = query.get("current").map(String::as_str);

    let store_urls = StoreUrls {
        android: "https://play.google.com/store/apps/details?id=com.reallystick",
        ios: "https://apps.apple.com/app/id1234567890",
    };

    let data = VersionInfo {
        min_version: "0.0.1",
        latest_version: "0.0.1",
        update_required: false,
        changelog: "",
        store_url: store_urls,
    };

    HttpResponse::Ok().json(data)
}
