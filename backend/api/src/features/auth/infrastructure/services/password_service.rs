// Password service - handles password validation

use crate::core::constants::errors::AppError;
use crate::features::profile::domain::entities::User;
use argon2::{Argon2, PasswordHash, PasswordVerifier};

pub struct PasswordService;

impl Default for PasswordService {
    fn default() -> Self {
        Self::new()
    }
}

impl PasswordService {
    pub fn new() -> Self {
        Self
    }

    pub fn is_valid(&self, user: &User, password: &str) -> bool {
        let parsed_hash = match PasswordHash::new(&user.password) {
            Ok(parsed_hash) => parsed_hash,
            Err(_) => return false,
        };

        let argon2 = Argon2::default();
        argon2
            .verify_password(password.as_bytes(), &parsed_hash)
            .is_ok()
    }

    pub fn verify_recovery_code(&self, recovery_code_hash: &str, provided_code: &str) -> bool {
        let parsed_hash = match PasswordHash::new(recovery_code_hash) {
            Ok(hash) => hash,
            Err(_) => return false,
        };

        let argon2 = Argon2::default();
        argon2
            .verify_password(provided_code.as_bytes(), &parsed_hash)
            .is_ok()
    }

    pub fn is_long_enough(&self, input: &str) -> bool {
        input.len() >= 8
    }

    pub fn is_strong_enough(&self, input: &str) -> bool {
        let has_letter = input.chars().any(|c| c.is_alphabetic());
        let has_digit = input.chars().any(|c| c.is_ascii_digit());
        let has_special = input.chars().any(|c| c.is_ascii_punctuation());
        let valid_characters = input
            .chars()
            .all(|c| c.is_alphanumeric() || c.is_ascii_punctuation());
        has_letter && has_digit && has_special && valid_characters
    }

    pub fn validate(&self, input: &str) -> Option<AppError> {
        if !self.is_long_enough(input) {
            return Some(AppError::PasswordTooShort);
        }

        if !self.is_strong_enough(input) {
            return Some(AppError::PasswordTooWeak);
        }

        None
    }
}
