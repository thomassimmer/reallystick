use crate::{
    core::structs::responses::GenericResponse,
    features::{
        challenges::structs::models::{
            challenge::CHALLENGE_DESCRIPTION_MAX_LENGTH,
            challenge_daily_tracking::CHALLENGE_DAILY_TRACKING_NOTE_MAX_LENGTH,
        },
        habits::structs::models::habit::HABIT_DESCRIPTION_MAX_LENGTH,
        private_discussions::structs::models::private_message::PRIVATE_MESSAGE_CONTENT_MAX_LENGTH,
        public_discussions::structs::models::{
            public_message::PUBLIC_MESSAGE_CONTENT_MAX_LENGTH,
            public_message_report::PUBLIC_MESSAGE_REPORT_CONTENT_MAX_LENGTH,
        },
    },
};

#[derive(Debug)]
pub enum AppError {
    AccessTokenExpired,
    BothHabitAndChallengePassed,
    ChallengeCreation,
    ChallengeDailyTrackingCreation,
    ChallengeDailyTrackingDelete,
    ChallengeDailyTrackingNoteTooLong,
    ChallengeDailyTrackingNotFound,
    ChallengeDailyTrackingUpdate,
    ChallengeDelete,
    ChallengeDescriptionTooLong,
    ChallengeNotFound,
    ChallengeParticipationAlreadyExisting,
    ChallengeParticipationCreation,
    ChallengeParticipationDelete,
    ChallengeParticipationNotFound,
    ChallengeParticipationUpdate,
    ChallengeUpdate,
    DatabaseConnection,
    DatabaseQuery,
    DatabaseTransaction,
    FailedToCreateSocketSession,
    InvalidAccessToken,
    InvalidChallengeCreator,
    InvalidChallengeParticipationUser,
    InvalidOneTimePassword,
    InvalidRefreshToken,
    InvalidUsernameOrCodeOrRecoveryCode,
    InvalidUsernameOrPassword,
    InvalidUsernameOrPasswordOrRecoveryCode,
    InvalidUsernameOrRecoveryCode,
    HabitCategoryCreation,
    HabitCategoryDelete,
    HabitCategoryNotFound,
    HabitCreation,
    HabitDailyTrackingCreation,
    HabitDailyTrackingDelete,
    HabitDailyTrackingNotFound,
    HabitDailyTrackingUpdate,
    HabitDelete,
    HabitDescriptionTooLong,
    HabitMerge,
    HabitNotFound,
    HabitParticipationCreation,
    HabitParticipationDelete,
    HabitParticipationNotFound,
    HabitParticipationUpdate,
    HabitUpdate,
    NoHabitNorChallengePassed,
    NotAdmin,
    PasswordHash,
    PasswordTooShort,
    PasswordTooWeak,
    PrivateDiscussionCreation,
    PrivateDiscussionParticipationCreation,
    PrivateDiscussionParticipationNotFound,
    PrivateDiscussionParticipationUpdate,
    PrivateDiscussionNotFound,
    PrivateMessageContentEmpty,
    PrivateMessageContentTooLong,
    PrivateMessageCreation,
    PrivateMessageDeletion,
    PrivateMessageDeletionNotDoneByCreator,
    PrivateMessageNotFound,
    PrivateMessageUpdate,
    PrivateMessageUpdateNotDoneByCreator,
    PublicMessageContentEmpty,
    PublicMessageContentTooLong,
    PublicMessageCreation,
    PublicMessageDeletion,
    PublicMessageDeletionNotDoneByAdmin,
    PublicMessageDeletionNotDoneByCreator,
    PublicMessageLikeCreation,
    PublicMessageLikeDeletion,
    PublicMessageReportCreation,
    PublicMessageReportDeletion,
    PublicMessageReportNotFound,
    PublicMessageReportReasonEmpty,
    PublicMessageReportReasonTooLong,
    PublicMessageReportReporterIsNotRequestUser,
    PublicMessageNeedsHabitOrChallenge,
    PublicMessageNotFound,
    PublicMessageUpdate,
    RecoveryCodeCreation,
    RecoveryCodeDeletion,
    RecoveryCodeHashCreation,
    TokenGeneration,
    TwoFactorAuthenticationNotEnabled,
    UnitCreation,
    UnitDelete,
    UnitNotFound,
    UnitUpdate,
    UsernameNotRespectingRules,
    UsernameWrongSize,
    UserAlreadyHasKeys,
    UserNotFound,
    UserTokenDeletion,
    UserTokenNotFound,
    UserTokenUpdate,
    UserUpdate,
}

impl AppError {
    pub fn to_response(&self) -> GenericResponse {
        match self {
            AppError::AccessTokenExpired => GenericResponse {
                code: "ACCESS_TOKEN_EXPIRED".to_string(),
                message: "Token expired".to_string(),
            },
            AppError::BothHabitAndChallengePassed => GenericResponse {
                code: "BOTH_HABIT_AND_CHALLENGE_PASSED".to_string(),
                message: "Both habit's id and challenge's id were passed".to_string(),
            },
            AppError::ChallengeCreation => GenericResponse {
                code: "CHALLENGE_NOT_CREATED".to_string(),
                message: "Failed to create this challenge".to_string(),
            },
            AppError::ChallengeDailyTrackingCreation => GenericResponse {
                code: "CHALLENGE_DAILY_TRACKING_NOT_CREATED".to_string(),
                message: "Failed to create this challenge daily tracking".to_string(),
            },
            AppError::ChallengeDailyTrackingDelete => GenericResponse {
                code: "CHALLENGE_DAILY_TRACKING_NOT_DELETED".to_string(),
                message: "Failed to delete this challenge daily tracking".to_string(),
            },
            AppError::ChallengeDailyTrackingNoteTooLong => GenericResponse {
                code: "CHALLENGE_DAILY_TRACKING_NOTE_TOO_LONG".to_string(),
                message: format!(
                    "The note is too long. It has to be no more than {} characters.",
                    CHALLENGE_DAILY_TRACKING_NOTE_MAX_LENGTH
                ),
            },
            AppError::ChallengeDailyTrackingNotFound => GenericResponse {
                code: "CHALLENGE_DAILY_TRACKING_NOT_FOUND".to_string(),
                message: "The challenge daily tracking requested does not exist".to_string(),
            },
            AppError::ChallengeDailyTrackingUpdate => GenericResponse {
                code: "CHALLENGE_DAILY_TRACKING_NOT_UPDATED".to_string(),
                message: "Failed to update challenge daily tracking".to_string(),
            },
            AppError::ChallengeDescriptionTooLong => GenericResponse {
                code: "CHALLENGE_DESCRIPTION_TOO_LONG".to_string(),
                message: format!(
                    "One translation of the description is more than {}",
                    CHALLENGE_DESCRIPTION_MAX_LENGTH
                ),
            },
            AppError::ChallengeDelete => GenericResponse {
                code: "CHALLENGE_NOT_DELETED".to_string(),
                message: "Failed to delete this challenge".to_string(),
            },
            AppError::ChallengeNotFound => GenericResponse {
                code: "CHALLENGE_NOT_FOUND".to_string(),
                message: "The challenge requested does not exist".to_string(),
            },
            AppError::ChallengeParticipationAlreadyExisting => GenericResponse {
                code: "CHALLENGE_PARTICIPATION_ALREADY_EXISTING".to_string(),
                message: "You already have an ongoing participation existing for this challenge"
                    .to_string(),
            },
            AppError::ChallengeParticipationCreation => GenericResponse {
                code: "CHALLENGE_PARTICIPATION_NOT_CREATED".to_string(),
                message: "Failed to create this challenge participation".to_string(),
            },
            AppError::ChallengeParticipationDelete => GenericResponse {
                code: "CHALLENGE_PARTICIPATION_NOT_DELETED".to_string(),
                message: "Failed to delete this challenge participation".to_string(),
            },
            AppError::ChallengeParticipationNotFound => GenericResponse {
                code: "CHALLENGE_PARTICIPATION_NOT_FOUND".to_string(),
                message: "The challenge participation requested does not exist".to_string(),
            },
            AppError::ChallengeParticipationUpdate => GenericResponse {
                code: "CHALLENGE_PARTICIPATION_NOT_UPDATED".to_string(),
                message: "Failed to update challenge participation".to_string(),
            },
            AppError::ChallengeUpdate => GenericResponse {
                code: "CHALLENGE_NOT_UPDATED".to_string(),
                message: "Failed to update challenge participation".to_string(),
            },
            AppError::DatabaseConnection => GenericResponse {
                code: "DATABASE_CONNECTION".to_string(),
                message: "Failed to get a transaction".to_string(),
            },
            AppError::DatabaseQuery => GenericResponse {
                code: "DATABASE_QUERY".to_string(),
                message: "Database query error".to_string(),
            },
            AppError::DatabaseTransaction => GenericResponse {
                code: "DATABASE_TRANSACTION".to_string(),
                message: "Failed to commit transaction".to_string(),
            },
            AppError::FailedToCreateSocketSession => GenericResponse {
                code: "FAILED_TO_CREATE_SOCKET_SESSION".to_string(),
                message: "Failed to create a web socket session".to_string(),
            },
            AppError::InvalidAccessToken => GenericResponse {
                code: "INVALID_ACCESS_TOKEN".to_string(),
                message: "Invalid access token".to_string(),
            },
            AppError::InvalidChallengeCreator => GenericResponse {
                code: "INVALID_CHALLENGE_CREATOR".to_string(),
                message: "You are not the creator of this challenge".to_string(),
            },
            AppError::InvalidChallengeParticipationUser => GenericResponse {
                code: "INVALID_CHALLENGE_PARTICIPATION_USER".to_string(),
                message: "You are not the user of this challenge participation".to_string(),
            },
            AppError::InvalidOneTimePassword => GenericResponse {
                code: "INVALID_ONE_TIME_PASSWORD".to_string(),
                message: "Invalid one time password".to_string(),
            },
            AppError::InvalidRefreshToken => GenericResponse {
                code: "INVALID_REFRESH_TOKEN".to_string(),
                message: "Invalid refresh token".to_string(),
            },
            AppError::InvalidUsernameOrCodeOrRecoveryCode => GenericResponse {
                code: "INVALID_USERNAME_OR_CODE_OR_RECOVERY_CODE".to_string(),
                message: "Invalid username or code or recovery code".to_string(),
            },
            AppError::InvalidUsernameOrPassword => GenericResponse {
                code: "INVALID_USERNAME_OR_PASSWORD".to_string(),
                message: "Invalid username or password".to_string(),
            },
            AppError::InvalidUsernameOrPasswordOrRecoveryCode => GenericResponse {
                code: "INVALID_USERNAME_OR_PASSWORD_OR_RECOVERY_CODE".to_string(),
                message: "Invalid username or password or recovery code".to_string(),
            },
            AppError::InvalidUsernameOrRecoveryCode => GenericResponse {
                code: "INVALID_USERNAME_OR_RECOVERY_CODE".to_string(),
                message: "Invalid username or recovery code".to_string(),
            },
            AppError::HabitCategoryCreation => GenericResponse {
                code: "HABIT_CATEGORY_NOT_CREATED".to_string(),
                message: "Failed to create this habit category".to_string(),
            },
            AppError::HabitCategoryDelete => GenericResponse {
                code: "HABIT_CATEGORY_NOT_DELETED".to_string(),
                message: "Failed to delete this habit category".to_string(),
            },
            AppError::HabitCategoryNotFound => GenericResponse {
                code: "HABIT_CATEGORY_NOT_FOUND".to_string(),
                message: "The habit category requested does not exist".to_string(),
            },
            AppError::HabitCreation => GenericResponse {
                code: "HABIT_NOT_CREATED".to_string(),
                message: "Failed to create this habit".to_string(),
            },
            AppError::HabitDailyTrackingCreation => GenericResponse {
                code: "HABIT_DAILY_TRACKING_NOT_CREATED".to_string(),
                message: "Failed to create this habit daily tracking".to_string(),
            },
            AppError::HabitDailyTrackingDelete => GenericResponse {
                code: "HABIT_DAILY_TRACKING_NOT_DELETED".to_string(),
                message: "Failed to delete this habit daily tracking".to_string(),
            },
            AppError::HabitDailyTrackingNotFound => GenericResponse {
                code: "HABIT_DAILY_TRACKING_NOT_FOUND".to_string(),
                message: "The habit daily tracking requested does not exist".to_string(),
            },
            AppError::HabitDailyTrackingUpdate => GenericResponse {
                code: "HABIT_DAILY_TRACKING_NOT_UPDATED".to_string(),
                message: "Failed to update habit daily tracking".to_string(),
            },
            AppError::HabitDelete => GenericResponse {
                code: "HABIT_NOT_DELETED".to_string(),
                message: "Failed to delete this habit".to_string(),
            },
            AppError::HabitDescriptionTooLong => GenericResponse {
                code: "HABIT_DESCRIPTION_TOO_LONG".to_string(),
                message: format!(
                    "One translation of the description is more than {}",
                    HABIT_DESCRIPTION_MAX_LENGTH
                ),
            },
            AppError::HabitMerge => GenericResponse {
                code: "HABITS_NOT_MERGED".to_string(),
                message: "Failed to merge these two habits".to_string(),
            },
            AppError::HabitNotFound => GenericResponse {
                code: "HABIT_NOT_FOUND".to_string(),
                message: "The habit requested does not exist".to_string(),
            },
            AppError::HabitParticipationCreation => GenericResponse {
                code: "HABIT_PARTICIPATION_NOT_CREATED".to_string(),
                message: "Failed to create this habit participation".to_string(),
            },
            AppError::HabitParticipationDelete => GenericResponse {
                code: "HABIT_PARTICIPATION_NOT_DELETED".to_string(),
                message: "Failed to delete this habit participation".to_string(),
            },
            AppError::HabitParticipationNotFound => GenericResponse {
                code: "HABIT_PARTICIPATION_NOT_FOUND".to_string(),
                message: "The habit participation requested does not exist".to_string(),
            },
            AppError::HabitParticipationUpdate => GenericResponse {
                code: "HABIT_PARTICIPATION_UPDATE".to_string(),
                message: "Failed to update habit participation".to_string(),
            },
            AppError::HabitUpdate => GenericResponse {
                code: "HABIT_UPDATE".to_string(),
                message: "Failed to update habit".to_string(),
            },
            AppError::NoHabitNorChallengePassed => GenericResponse {
                code: "NO_HABIT_NOR_CHALLENGE_PASSED".to_string(),
                message: "No habit's id nor challenge's id were passed".to_string(),
            },
            AppError::NotAdmin => GenericResponse {
                code: "NOT_ADMIN".to_string(),
                message: "You are not administrator".to_string(),
            },
            AppError::PasswordHash => GenericResponse {
                code: "PASSWORD_HASH".to_string(),
                message: "Failed to retrieve hashed password".to_string(),
            },
            AppError::PasswordTooShort => GenericResponse {
                code: "PASSWORD_TOO_SHORT".to_string(),
                message: "This password is too short".to_string(),
            },
            AppError::PasswordTooWeak => GenericResponse {
                code: "PASSWORD_TOO_WEAK".to_string(),
                message: "This password is too weak".to_string(),
            },
            AppError::PrivateDiscussionCreation => GenericResponse {
                code: "PRIVATE_DISCUSSION_CREATION".to_string(),
                message: "Failed to create this private discussion.".to_string(),
            },
            AppError::PrivateDiscussionParticipationCreation => GenericResponse {
                code: "PRIVATE_DISCUSSION_PARTICIPATION_CREATION".to_string(),
                message: "Failed to create this private discussion participation.".to_string(),
            },
            AppError::PrivateDiscussionParticipationNotFound => GenericResponse {
                code: "PRIVATE_DISCUSSION_PARTICIPATION_NOT_FOUND".to_string(),
                message: "The private discussion participation was not found.".to_string(),
            },
            AppError::PrivateDiscussionParticipationUpdate => GenericResponse {
                code: "PRIVATE_DISCUSSION_PARTICIPATION_UPDATE".to_string(),
                message: "Failed to update the private discussion participation.".to_string(),
            },
            AppError::PrivateDiscussionNotFound => GenericResponse {
                code: "PRIVATE_DISCUSSION_NOT_FOUND".to_string(),
                message: "The private discussion was not found.".to_string(),
            },
            AppError::PrivateMessageContentEmpty => GenericResponse {
                code: "PRIVATE_MESSAGE_CONTENT_EMPTY".to_string(),
                message: "A private message's content must not be empty.".to_string(),
            },
            AppError::PrivateMessageContentTooLong => GenericResponse {
                code: "PRIVATE_MESSAGE_CONTENT_TOO_LONG".to_string(),
                message: format!(
                    "A private message's content must be less than {} characters.",
                    PRIVATE_MESSAGE_CONTENT_MAX_LENGTH
                ),
            },
            AppError::PrivateMessageCreation => GenericResponse {
                code: "PRIVATE_MESSAGE_CREATION".to_string(),
                message: "Failed to create this private message.".to_string(),
            },
            AppError::PrivateMessageDeletion => GenericResponse {
                code: "PRIVATE_MESSAGE_DELETION".to_string(),
                message: "Failed to delete this private message.".to_string(),
            },
            AppError::PrivateMessageDeletionNotDoneByCreator => GenericResponse {
                code: "PRIVATE_MESSAGE_DELETION_NOT_DONE_BY_CREATOR".to_string(),
                message: "You can only delete a private message that you created.".to_string(),
            },
            AppError::PrivateMessageNotFound => GenericResponse {
                code: "PRIVATE_MESSAGE_NOT_FOUND".to_string(),
                message: "The private message was not found.".to_string(),
            },
            AppError::PrivateMessageUpdate => GenericResponse {
                code: "PRIVATE_MESSAGE_UPDATE".to_string(),
                message: "Failed to update this private message.".to_string(),
            },
            AppError::PrivateMessageUpdateNotDoneByCreator => GenericResponse {
                code: "PRIVATE_MESSAGE_UPDATE_NOT_DONE_BY_CREATOR".to_string(),
                message: "You can only update a private message that you created.".to_string(),
            },
            AppError::PublicMessageCreation => GenericResponse {
                code: "PUBLIC_MESSAGE_CREATION".to_string(),
                message: "Failed to create this message".to_string(),
            },
            AppError::PublicMessageDeletion => GenericResponse {
                code: "PUBLIC_MESSAGE_DELETION".to_string(),
                message: "Failed to delete this message".to_string(),
            },
            AppError::PublicMessageDeletionNotDoneByAdmin => GenericResponse {
                code: "PUBLIC_MESSAGE_DELETION_NOT_DONE_BY_ADMIN".to_string(),
                message: "You are not an admin".to_string(),
            },
            AppError::PublicMessageDeletionNotDoneByCreator => GenericResponse {
                code: "PUBLIC_MESSAGE_DELETION_NOT_DONE_BY_CREATOR".to_string(),
                message: "You are not the creator of this message".to_string(),
            },
            AppError::PublicMessageContentEmpty => GenericResponse {
                code: "PUBLIC_MESSAGE_CONTENT_EMPTY".to_string(),
                message: "A public message's content must not be empty.".to_string(),
            },
            AppError::PublicMessageContentTooLong => GenericResponse {
                code: "PUBLIC_MESSAGE_CONTENT_TOO_LONG".to_string(),
                message: format!(
                    "A public message's content must be less than {} characters.",
                    PUBLIC_MESSAGE_CONTENT_MAX_LENGTH
                ),
            },
            AppError::PublicMessageLikeCreation => GenericResponse {
                code: "PUBLIC_MESSAGE_LIKE_CREATION".to_string(),
                message: "Failed to create this like".to_string(),
            },
            AppError::PublicMessageLikeDeletion => GenericResponse {
                code: "PUBLIC_MESSAGE_LIKE_DELETION".to_string(),
                message: "Failed to delete this like".to_string(),
            },
            AppError::PublicMessageReportCreation => GenericResponse {
                code: "PUBLIC_MESSAGE_REPORT_CREATION".to_string(),
                message: "Failed to create this report".to_string(),
            },
            AppError::PublicMessageReportDeletion => GenericResponse {
                code: "PUBLIC_MESSAGE_REPORT_DELETION".to_string(),
                message: "Failed to delete this report".to_string(),
            },
            AppError::PublicMessageReportNotFound => GenericResponse {
                code: "PUBLIC_MESSAGE_REPORT_NOT_FOUND".to_string(),
                message: "This message report does not exist".to_string(),
            },
            AppError::PublicMessageReportReasonEmpty => GenericResponse {
                code: "PUBLIC_MESSAGE_REPORT_REASON_EMPTY".to_string(),
                message: "A public message report's reason must not be empty.".to_string(),
            },
            AppError::PublicMessageReportReasonTooLong => GenericResponse {
                code: "PUBLIC_MESSAGE_REPORT_REASON_TOO_LONG".to_string(),
                message: format!(
                    "A public message report's reason must be less than {} characters.",
                    PUBLIC_MESSAGE_REPORT_CONTENT_MAX_LENGTH
                ),
            },
            AppError::PublicMessageReportReporterIsNotRequestUser => GenericResponse {
                code: "PUBLIC_MESSAGE_REPORT_REPORTER_IS_NOT_REQUEST_USER".to_string(),
                message: "This message report wad not created by you".to_string(),
            },
            AppError::PublicMessageNeedsHabitOrChallenge => GenericResponse {
                code: "PUBLIC_MESSAGE_NEEDS_HABIT_OR_CHALLENGE".to_string(),
                message: "A public message must be associated to a habit or a challenge."
                    .to_string(),
            },
            AppError::PublicMessageNotFound => GenericResponse {
                code: "PUBLIC_MESSAGE_NOT_FOUND".to_string(),
                message: "This public message does not exist.".to_string(),
            },
            AppError::PublicMessageUpdate => GenericResponse {
                code: "PUBLIC_MESSAGE_UPDATE".to_string(),
                message: "Failed to update this message".to_string(),
            },
            AppError::RecoveryCodeDeletion => GenericResponse {
                code: "RECOVERY_CODE_DELETION".to_string(),
                message: "Failed to delete the recovery code.".to_string(),
            },
            AppError::RecoveryCodeCreation => GenericResponse {
                code: "RECOVERY_CODE_CREATION".to_string(),
                message: "Failed to create the recovery code.".to_string(),
            },
            AppError::RecoveryCodeHashCreation => GenericResponse {
                code: "RECOVERY_CODE_HASH_CREATION".to_string(),
                message: "Failed to create a hash for the recovery code.".to_string(),
            },
            AppError::TokenGeneration => GenericResponse {
                code: "TOKEN_GENERATION".to_string(),
                message: "Failed to generate and save token".to_string(),
            },
            AppError::TwoFactorAuthenticationNotEnabled => GenericResponse {
                code: "TWO_FACTOR_AUTHENTICATION_NOT_ENABLED".to_string(),
                message: "Two factor authentication is not enabled".to_string(),
            },
            AppError::UnitCreation => GenericResponse {
                code: "UNIT_NOT_CREATED".to_string(),
                message: "Failed to create this unit".to_string(),
            },
            AppError::UnitDelete => GenericResponse {
                code: "UNIT_NOT_DELETED".to_string(),
                message: "Failed to delete this unit".to_string(),
            },
            AppError::UnitNotFound => GenericResponse {
                code: "UNIT_NOT_FOUND".to_string(),
                message: "The unit requested does not exist".to_string(),
            },
            AppError::UnitUpdate => GenericResponse {
                code: "UNIT_UPDATE".to_string(),
                message: "Failed to update unit".to_string(),
            },
            AppError::UsernameNotRespectingRules => GenericResponse {
                code: "USERNAME_NOT_RESPECTING_RULES".to_string(),
                message: "This username is not respecting our rules".to_string(),
            },
            AppError::UsernameWrongSize => GenericResponse {
                code: "USERNAME_WRONG_SIZE".to_string(),
                message: "This username is too short or too long".to_string(),
            },
            AppError::UserAlreadyHasKeys => GenericResponse {
                code: "USER_HAS_ALREADY_KEYS".to_string(),
                message: "You already have keys".to_string(),
            },
            AppError::UserNotFound => GenericResponse {
                code: "USER_NOT_FOUND".to_string(),
                message: "This user does not exist".to_string(),
            },
            AppError::UserTokenDeletion => GenericResponse {
                code: "USER_TOKEN_DELETION".to_string(),
                message: "Failed to delete user tokens into the database".to_string(),
            },
            AppError::UserTokenNotFound => GenericResponse {
                code: "USER_TOKEN_NOT_FOUND".to_string(),
                message: "This user token does not exist".to_string(),
            },
            AppError::UserTokenUpdate => GenericResponse {
                code: "USER_TOKEN_UPDATE".to_string(),
                message: "Failed to update user token".to_string(),
            },
            AppError::UserUpdate => GenericResponse {
                code: "USER_UPDATE".to_string(),
                message: "Failed to update user".to_string(),
            },
        }
    }
}

// TODO: To reduce boilerplate code in every routes.
// impl From<sqlx::Error> for AppError {
//     fn from(error: sqlx::Error) -> Self {
//         match error {
//             _ => AppError::DatabaseConnection, // Default to InternalServerError
//         }
//     }
// }

// impl fmt::Display for AppError {
//     fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
//         write!(f, "{:?}", self)
//     }
// }

// impl ResponseError for AppError {
//     fn error_response(&self) -> HttpResponse {
//         match self {
//             AppError::ChallengeNotFound => HttpResponse::NotFound().json(self.to_response()),
//             AppError::UnitNotFound => HttpResponse::NotFound().json(self.to_response()),
//             AppError::HabitNotFound => HttpResponse::NotFound().json(self.to_response()),
//             AppError::UserTokenNotFound => HttpResponse::NotFound().json(self.to_response()),
//             AppError::HabitCategoryNotFound => HttpResponse::NotFound().json(self.to_response()),
//             AppError::PublicMessageNotFound => HttpResponse::NotFound().json(self.to_response()),
//             AppError::PrivateMessageNotFound => HttpResponse::NotFound().json(self.to_response()),
//             AppError::PrivateDiscussionNotFound => {
//                 HttpResponse::NotFound().json(self.to_response())
//             }
//             AppError::HabitDailyTrackingNotFound => {
//                 HttpResponse::NotFound().json(self.to_response())
//             }
//             AppError::HabitParticipationNotFound => {
//                 HttpResponse::NotFound().json(self.to_response())
//             }
//             AppError::PublicMessageReportNotFound => {
//                 HttpResponse::NotFound().json(self.to_response())
//             }
//             AppError::ChallengeDailyTrackingNotFound => {
//                 HttpResponse::NotFound().json(self.to_response())
//             }
//             AppError::PrivateDiscussionParticipationNotFound => {
//                 HttpResponse::NotFound().json(self.to_response())
//             }
//             AppError::InvalidChallengeCreator => HttpResponse::Forbidden().json(self.to_response()),
//             AppError::InvalidChallengeCreator => HttpResponse::Forbidden().json(self.to_response()),
//             AppError::InvalidChallengeCreator => HttpResponse::Forbidden().json(self.to_response()),
//             AppError::InvalidChallengeCreator => HttpResponse::Forbidden().json(self.to_response()),

//             AppError::UserNotFound => HttpResponse::NotFound().json(self.to_response()),
//             _ => HttpResponse::InternalServerError().json(self.to_response()),
//         }
//     }
// }
