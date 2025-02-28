use crate::core::structs::responses::GenericResponse;

pub enum AppError {
    AccessTokenExpired,
    DatabaseConnection,
    DatabaseQuery,
    DatabaseTransaction,
    InvalidAccessToken,
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
    HabitNotFound,
    HabitParticipationCreation,
    HabitParticipationDelete,
    HabitParticipationNotFound,
    HabitParticipationUpdate,
    HabitUpdate,
    PasswordHash,
    PasswordTooShort,
    PasswordTooWeak,
    TokenGeneration,
    TwoFactorAuthenticationNotEnabled,
    UsernameNotRespectingRules,
    UsernameWrongSize,
    UserTokenDeletion,
    UserUpdate,
}

impl AppError {
    pub fn to_response(&self) -> GenericResponse {
        match self {
            AppError::AccessTokenExpired => GenericResponse {
                code: "ACCESS_TOKEN_EXPIRED".to_string(),
                message: "Token expired".to_string(),
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
            AppError::InvalidAccessToken => GenericResponse {
                code: "INVALID_ACCESS_TOKEN".to_string(),
                message: "Invalid access token".to_string(),
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
                code: "HABIT_DAILY_TRACKING_UPDATE".to_string(),
                message: "Failed to update habit daily tracking".to_string(),
            },
            AppError::HabitDelete => GenericResponse {
                code: "HABIT_NOT_DELETED".to_string(),
                message: "Failed to delete this habit".to_string(),
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
            AppError::TokenGeneration => GenericResponse {
                code: "TOKEN_GENERATION".to_string(),
                message: "Failed to generate and save token".to_string(),
            },
            AppError::TwoFactorAuthenticationNotEnabled => GenericResponse {
                code: "TWO_FACTOR_AUTHENTICATION_NOT_ENABLED".to_string(),
                message: "Two factor authentication is not enabled".to_string(),
            },
            AppError::UsernameNotRespectingRules => GenericResponse {
                code: "USERNAME_NOT_RESPECTING_RULES".to_string(),
                message: "This username is not respecting our rules".to_string(),
            },
            AppError::UsernameWrongSize => GenericResponse {
                code: "USERNAME_WRONG_SIZE".to_string(),
                message: "This username is too short or too long".to_string(),
            },
            AppError::UserTokenDeletion => GenericResponse {
                code: "USER_TOKEN_DELETION".to_string(),
                message: "Failed to delete user tokens into the database".to_string(),
            },
            AppError::UserUpdate => GenericResponse {
                code: "USER_UPDATE".to_string(),
                message: "Failed to update user".to_string(),
            },
        }
    }
}
