pub mod configuration;
pub mod startup;

pub mod core {

    pub mod constants {
        pub mod errors;
    }

    pub mod routes {
        pub mod health_check;
    }

    pub mod helpers {
        pub mod mock_now;
        pub mod startup;
    }

    pub mod structs {
        pub mod responses;
    }

    pub mod middlewares {
        pub mod token_validator;
    }
}

pub mod features {
    pub mod auth {
        pub mod helpers {
            pub mod errors;
            pub mod password;
            pub mod token;
            pub mod username;
        }

        pub mod routes {
            pub mod disable_otp;
            pub mod generate_otp;
            pub mod log_user_in;
            pub mod recover_account_using_2fa;
            pub mod recover_account_using_password;
            pub mod recover_account_without_2fa_enabled;
            pub mod signup;
            pub mod token;
            pub mod validate_otp;
            pub mod verify_otp;
        }

        pub mod structs {
            pub mod models;
            pub mod requests;
            pub mod responses;
        }
    }

    pub mod profile {
        pub mod routes {
            pub mod delete_account;
            pub mod get_profile_information;
            pub mod is_otp_enabled;
            pub mod post_profile_information;
            pub mod set_password;
            pub mod update_password;
        }

        pub mod structs {
            pub mod models;
            pub mod requests;
            pub mod responses;
        }

        pub mod helpers {
            pub mod user;
        }
    }

    pub mod habits {
        pub mod routes {
            pub mod create_habit;
            pub mod create_habit_category;
            pub mod create_habit_daily_tracking;
            pub mod create_habit_participation;
            pub mod create_unit;
            pub mod delete_habit;
            pub mod delete_habit_category;
            pub mod delete_habit_daily_tracking;
            pub mod delete_habit_participation;
            pub mod get_habit;
            pub mod get_habit_categories;
            pub mod get_habit_daily_trackings;
            pub mod get_habit_participations;
            pub mod get_habit_statistics;
            pub mod get_habits;
            pub mod get_units;
            pub mod merge_habits;
            pub mod update_habit;
            pub mod update_habit_category;
            pub mod update_habit_daily_tracking;
            pub mod update_habit_participation;
            pub mod update_unit;
        }

        pub mod structs {
            pub mod models {
                pub mod habit;
                pub mod habit_category;
                pub mod habit_daily_tracking;
                pub mod habit_participation;
                pub mod habit_statistics;
                pub mod unit;
            }

            pub mod requests {
                pub mod habit;
                pub mod habit_category;
                pub mod habit_daily_tracking;
                pub mod habit_participation;
                pub mod unit;
            }

            pub mod responses {
                pub mod habit;
                pub mod habit_category;
                pub mod habit_daily_tracking;
                pub mod habit_participation;
                pub mod unit;
            }
        }

        pub mod helpers {
            pub mod habit;
            pub mod habit_category;
            pub mod habit_daily_tracking;
            pub mod habit_participation;
            pub mod unit;
        }
    }

    pub mod challenges {
        pub mod routes {
            pub mod create_challenge;
            pub mod create_challenge_daily_tracking;
            pub mod create_challenge_participation;
            pub mod delete_challenge;
            pub mod delete_challenge_daily_tracking;
            pub mod delete_challenge_participation;
            pub mod get_challenge;
            pub mod get_challenge_daily_trackings;
            pub mod get_challenge_participations;
            pub mod get_challenge_statistics;
            pub mod get_challenges;
            pub mod update_challenge;
            pub mod update_challenge_daily_tracking;
            pub mod update_challenge_participation;
        }

        pub mod structs {
            pub mod models {
                pub mod challenge;
                pub mod challenge_daily_tracking;
                pub mod challenge_participation;
                pub mod challenge_statistics;
            }

            pub mod requests {
                pub mod challenge;
                pub mod challenge_daily_tracking;
                pub mod challenge_participation;
            }

            pub mod responses {
                pub mod challenge;
                pub mod challenge_daily_tracking;
                pub mod challenge_participation;
            }
        }

        pub mod helpers {
            pub mod challenge;
            pub mod challenge_daily_tracking;
            pub mod challenge_participation;
        }
    }
}
