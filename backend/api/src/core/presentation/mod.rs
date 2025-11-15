// Core presentation layer - shared routes, middlewares, etc.

pub mod middlewares {
    pub mod token_validator;
}

pub mod routes {
    pub mod health_check;
    pub mod version;
}
