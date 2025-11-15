use actix_web::{
    get,
    web::{Data, ReqData},
    HttpResponse, Responder,
};
use sqlx::PgPool;
use tracing::error;

use api::{
    core::{constants::errors::AppError, structs::responses::StatisticsResponse},
    features::{
        auth::{
            domain::repositories::UserTokenRepository,
            infrastructure::repositories::user_token_repository::UserTokenRepositoryImpl,
            structs::models::Claims,
        },
        challenges::{
            domain::repositories::{
                challenge_daily_tracking_repository::ChallengeDailyTrackingRepository,
                challenge_participation_repository::ChallengeParticipationRepository,
                ChallengeRepository,
            },
            infrastructure::repositories::{
                challenge_daily_tracking_repository::ChallengeDailyTrackingRepositoryImpl,
                challenge_participation_repository::ChallengeParticipationRepositoryImpl,
                challenge_repository::ChallengeRepositoryImpl,
            },
        },
        habits::{
            domain::repositories::{
                habit_category_repository::HabitCategoryRepository,
                habit_daily_tracking_repository::HabitDailyTrackingRepository,
                habit_participation_repository::HabitParticipationRepository,
                habit_repository::HabitRepository, unit_repository::UnitRepository,
            },
            infrastructure::repositories::{
                habit_category_repository::HabitCategoryRepositoryImpl,
                habit_daily_tracking_repository::HabitDailyTrackingRepositoryImpl,
                habit_participation_repository::HabitParticipationRepositoryImpl,
                habit_repository::HabitRepositoryImpl, unit_repository::UnitRepositoryImpl,
            },
        },
        notifications::{
            domain::repositories::NotificationRepository,
            infrastructure::repositories::notification_repository::NotificationRepositoryImpl,
        },
        private_discussions::{
            domain::{
                entities::channels_data::ChannelsData,
                repositories::{
                    private_discussion_repository::PrivateDiscussionRepository,
                    private_message_repository::PrivateMessageRepository,
                },
            },
            infrastructure::repositories::{
                private_discussion_repository::PrivateDiscussionRepositoryImpl,
                private_message_repository::PrivateMessageRepositoryImpl,
            },
        },
        profile::{
            domain::repositories::UserRepository,
            infrastructure::repositories::user_repository::UserRepositoryImpl,
        },
        public_discussions::{
            domain::repositories::{
                public_message_like_repository::PublicMessageLikeRepository,
                public_message_report_repository::PublicMessageReportRepository,
                public_message_repository::PublicMessageRepository,
            },
            infrastructure::repositories::{
                public_message_like_repository::PublicMessageLikeRepositoryImpl,
                public_message_report_repository::PublicMessageReportRepositoryImpl,
                public_message_repository::PublicMessageRepositoryImpl,
            },
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

    let user_repo = UserRepositoryImpl::new((**pool).clone());
    let user_count = user_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let token_repo = UserTokenRepositoryImpl::new((**pool).clone());
    let user_token_count = token_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let habit_repo = HabitRepositoryImpl::new((**pool).clone());
    let habit_count = habit_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let habit_category_repo = HabitCategoryRepositoryImpl::new((**pool).clone());
    let habit_category_count = habit_category_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let habit_participation_repo = HabitParticipationRepositoryImpl::new((**pool).clone());
    let habit_participation_count = habit_participation_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let habit_daily_tracking_repo = HabitDailyTrackingRepositoryImpl::new((**pool).clone());
    let habit_daily_tracking_count = habit_daily_tracking_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let challenge_repo = ChallengeRepositoryImpl::new((**pool).clone());
    let challenge_count = challenge_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let participation_repo = ChallengeParticipationRepositoryImpl::new((**pool).clone());
    let challenge_participation_count = participation_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let daily_tracking_repo = ChallengeDailyTrackingRepositoryImpl::new((**pool).clone());
    let challenge_daily_tracking_count = daily_tracking_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let unit_repo = UnitRepositoryImpl::new((**pool).clone());
    let unit_count = unit_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let notification_repo = NotificationRepositoryImpl::new((**pool).clone());
    let notification_count = notification_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let private_discussion_repo = PrivateDiscussionRepositoryImpl::new((**pool).clone());
    let private_discussion_count = private_discussion_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let private_message_repo = PrivateMessageRepositoryImpl::new((**pool).clone());
    let private_message_count = private_message_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let public_message_repo = PublicMessageRepositoryImpl::new((**pool).clone());
    let public_message_count = public_message_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let public_message_like_repo = PublicMessageLikeRepositoryImpl::new((**pool).clone());
    let public_message_like_count = public_message_like_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
        })
        .unwrap();
    let public_message_report_repo = PublicMessageReportRepositoryImpl::new((**pool).clone());
    let public_message_report_count = public_message_report_repo
        .count()
        .await
        .map_err(|e| {
            error!("Error: {}", e);
            HttpResponse::InternalServerError().json(AppError::DatabaseConnection.to_response())
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
