use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

use crate::{
    core::{constants::errors::AppError, structs::responses::StatisticsResponse},
    features::{
        auth::{helpers::token::get_user_token_count, structs::models::Claims},
        challenges::helpers::{
            challenge::get_challenge_count,
            challenge_daily_tracking::get_challenge_daily_tracking_count,
            challenge_participation::get_challenge_participation_count,
        },
        habits::helpers::{
            habit::get_habit_count, habit_category::get_habit_category_count,
            habit_daily_tracking::get_habit_daily_tracking_count,
            habit_participation::get_habit_participation_count, unit::get_unit_count,
        },
        notifications::helpers::notification::get_notification_count,
        private_discussions::{
            helpers::{
                private_discussion::get_private_discussion_count,
                private_message::get_private_message_count,
            },
            structs::models::channels_data::ChannelsData,
        },
        profile::helpers::profile::get_user_count,
        public_discussions::helpers::{
            public_message::get_public_message_count,
            public_message_like::get_public_message_like_count,
            public_message_report::get_public_message_report_count,
        },
    },
};

#[get("/statistics/")]
pub async fn statistics(
    pool: Data<PgPool>,
    request_claims: ReqData<Claims>,
    channels_data: Data<ChannelsData>,
) -> impl Responder {
    if !request_claims.is_admin {
        return HttpResponse::Forbidden().body("Access denied");
    }

    let user_count = get_user_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let user_token_count = get_user_token_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let habit_count = get_habit_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let habit_category_count = get_habit_category_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let habit_participation_count = get_habit_participation_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let habit_daily_tracking_count = get_habit_daily_tracking_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let challenge_count = get_challenge_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let challenge_participation_count = get_challenge_participation_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let challenge_daily_tracking_count = get_challenge_daily_tracking_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let unit_count = get_unit_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let notification_count = get_notification_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let private_discussion_count = get_private_discussion_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let private_message_count = get_private_message_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let public_message_count = get_public_message_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let public_message_like_count = get_public_message_like_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let public_message_report_count = get_public_message_report_count(&**pool)
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            return HttpResponse::InternalServerError()
                .json(AppError::DatabaseConnection.to_response());
        })
        .unwrap();
    let active_socket_count = channels_data.count_sessions().await as i64;

    HttpResponse::Ok().json(StatisticsResponse {
        code: "FETCHED_STATISTICS".to_string(),
        user_count,
        user_token_count,
        habit_category_count,
        habit_count,
        habit_daily_tracking_count,
        habit_participation_count,
        challenge_count,
        challenge_daily_tracking_count,
        challenge_participation_count,
        unit_count,
        notification_count,
        private_discussion_count,
        private_message_count,
        public_message_count,
        public_message_like_count,
        public_message_report_count,
        active_socket_count,
    })
}
