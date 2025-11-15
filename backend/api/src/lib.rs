pub mod configuration;
pub mod startup;

pub mod core {
    pub mod constants {
        pub mod errors;
    }

    pub mod helpers {
        pub mod mock_now;
        pub mod startup;
        pub mod translation;
        pub mod user_deletion;
    }

    pub mod structs {
        pub mod redis_messages;
        pub mod responses;
    }

    pub mod presentation;
}

pub mod features {
    pub mod auth {
        pub mod structs {
            pub mod models;
        }

        pub mod application;
        pub mod domain;
        pub mod infrastructure;
        pub mod presentation;
    }

    pub mod profile {
        pub mod helpers {
            pub mod device_info;
            pub mod redis_handler;
        }

        pub mod application;
        pub mod domain;
        pub mod infrastructure;
        pub mod presentation;
    }

    pub mod habits {
        pub mod application;
        pub mod domain;
        pub mod infrastructure;
        pub mod presentation;
    }

    pub mod challenges {
        pub mod application;
        pub mod domain;
        pub mod infrastructure;
        pub mod presentation;
    }

    pub mod public_discussions {
        pub mod application;
        pub mod domain;
        pub mod infrastructure;
        pub mod presentation;
    }

    pub mod private_discussions {
        pub mod application;
        pub mod domain;
        pub mod infrastructure;
        pub mod presentation;
    }

    pub mod notifications {
        pub mod application;
        pub mod domain;
        pub mod infrastructure;
        pub mod presentation;
    }
}
