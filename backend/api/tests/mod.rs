pub mod auth {
    pub mod login;
    pub mod otp;
    pub mod recovery {
        pub mod recover_account_using_2fa;
        pub mod recover_account_using_password;
        pub mod recover_account_without_2fa_enabled;
    }
    pub mod logout;
    pub mod recovery_code;
    pub mod signup;
    pub mod token;
}

#[allow(clippy::module_inception)]
pub mod profile {
    pub mod devices;
    pub mod profile;
    pub mod set_password;
    pub mod update_password;
    pub mod user_public_data;
}

pub mod core {
    pub mod health_check;
}

pub mod habits {
    pub mod habit;
    pub mod habit_category;
    pub mod habit_daily_tracking;
    pub mod habit_participation;
    pub mod unit;
}

pub mod challenges {
    pub mod challenge;
    pub mod challenge_daily_tracking;
    pub mod challenge_participation;
}

pub mod public_discussions {
    pub mod public_message;
    pub mod public_message_like;
    pub mod public_message_report;
}

pub mod private_discussions {
    pub mod private_discussion;
    pub mod private_discussion_participation;
    pub mod private_message;
}

#[allow(clippy::module_inception)]
pub mod notifications {
    pub mod notifications;
}

pub mod helpers;
