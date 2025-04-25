pub mod configuration;
pub mod startup;
pub mod startup_notifications;

pub mod core {

    pub mod constants {
        pub mod errors;
    }

    pub mod routes {
        pub mod health_check;
        pub mod statistics;
        pub mod version;
    }

    pub mod helpers {
        pub mod mock_now;
        pub mod startup;
        pub mod translation;
    }

    pub mod structs {
        pub mod redis_messages;
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
            pub mod recovery_code;
            pub mod token;
            pub mod username;
        }

        pub mod routes {
            pub mod disable_otp;
            pub mod generate_otp;
            pub mod log_user_in;
            pub mod log_user_out;
            pub mod recover_account_using_2fa;
            pub mod recover_account_using_password;
            pub mod recover_account_without_2fa_enabled;
            pub mod refresh_token;
            pub mod save_keys;
            pub mod save_recovery_code;
            pub mod signup;
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
            pub mod delete_device;
            pub mod get_devices;
            pub mod get_profile_information;
            pub mod get_user_data_by_username;
            pub mod get_users_data_by_id;
            pub mod is_otp_enabled;
            pub mod post_profile_information;
            pub mod set_fcm_token;
            pub mod set_password;
            pub mod update_password;
        }

        pub mod helpers {
            pub mod device_info;
            pub mod profile;
        }

        pub mod structs {
            pub mod models;
            pub mod requests;
            pub mod responses;
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
            pub mod duplicate_challenge;
            pub mod get_challenge;
            pub mod get_challenge_daily_trackings;
            pub mod get_challenge_participations;
            pub mod get_challenge_statistics;
            pub mod get_challenges;
            pub mod get_challenges_daily_trackings;
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

    pub mod public_discussions {
        pub mod helpers {
            pub mod public_message;
            pub mod public_message_like;
            pub mod public_message_report;
        }

        pub mod routes {
            pub mod create_public_message;
            pub mod create_public_message_like;
            pub mod create_public_message_report;
            pub mod delete_public_message;
            pub mod delete_public_message_like;
            pub mod delete_public_message_report;
            pub mod get_message;
            pub mod get_message_parents;
            pub mod get_message_reports;
            pub mod get_public_messages;
            pub mod get_replies;
            pub mod get_user_liked_messages;
            pub mod get_user_message_reports;
            pub mod get_user_written_messages;
            pub mod update_public_message;
        }

        pub mod structs {
            pub mod models {
                pub mod public_message;
                pub mod public_message_like;
                pub mod public_message_report;
            }

            pub mod requests {
                pub mod public_message;
                pub mod public_message_like;
                pub mod public_message_report;
            }

            pub mod responses {
                pub mod public_message;
                pub mod public_message_like;
                pub mod public_message_report;
            }
        }
    }

    pub mod private_discussions {
        pub mod helpers {
            pub mod private_discussion;
            pub mod private_discussion_participation;
            pub mod private_message;
        }

        pub mod structs {
            pub mod models {
                pub mod channels_data;
                pub mod private_discussion;
                pub mod private_discussion_participation;
                pub mod private_message;
                pub mod users_data;
            }

            pub mod requests {
                pub mod private_discussion;
                pub mod private_discussion_participation;
                pub mod private_message;
            }

            pub mod responses {
                pub mod private_discussion;
                pub mod private_discussion_participation;
                pub mod private_message;
            }
        }

        pub mod routes {
            pub mod create_private_discussion;
            pub mod create_private_message;
            pub mod delete_private_message;
            pub mod get_private_discussion_messages;
            pub mod get_private_discussions;
            pub mod mark_message_as_seen;
            pub mod update_private_discussion_participation;
            pub mod update_private_message;
            pub mod websocket;
        }
    }

    pub mod notifications {
        pub mod helpers {
            pub mod notification;
            pub mod redis_handler;
            pub mod reminders;
        }

        pub mod routes {
            pub mod delete_all_notifications;
            pub mod delete_notification;
            pub mod get_notifications;
            pub mod mark_notification_as_seen;
        }

        pub mod structs {
            pub mod models;
            pub mod requests;
            pub mod responses;
        }
    }

    pub mod oauth_fcm {
        // Copied from here with custom changes to the payload
        // https://github.com/ywegel/oauth_fcm/tree/master
        pub mod error;
        pub mod fcm;
        pub mod token_manager;
    }
}
