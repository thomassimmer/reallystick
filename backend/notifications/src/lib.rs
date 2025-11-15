pub mod startup;

pub mod core {
    pub mod presentation {
        pub mod routes {
            pub mod statistics;
        }
    }
}

pub mod features {
    pub mod notifications {
        pub mod helpers {
            pub mod redis_handler;
            pub mod reminders;
        }

        pub mod presentation {
            pub mod routes {
                pub mod websocket;
            }
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
