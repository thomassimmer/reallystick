// Username service - handles username validation

use crate::core::constants::errors::AppError;
use regex::Regex;

#[derive(Default)]
pub struct UsernameService;

impl UsernameService {
    pub fn new() -> Self {
        Self
    }

    pub fn has_good_size(&self, input: &str) -> bool {
        input.len() >= 3 && input.len() <= 20
    }

    pub fn respects_conventions(&self, input: &str) -> bool {
        // This regex means:
        // •	Starts with an alphanumeric character.
        // •	Allows alphanumeric characters, optionally separated by a single period, underscore, or hyphen.
        // •	Does not allow consecutive special characters.
        // •	Ends with an alphanumeric character.
        let pattern = Regex::new(r"^[\p{L}\p{N}]([._-]?[\p{L}\p{N}]+)*$").unwrap();
        pattern.is_match(input)
    }

    pub fn validate(&self, input: &str) -> Option<AppError> {
        if !self.has_good_size(input) {
            return Some(AppError::UsernameWrongSize);
        }

        if !self.respects_conventions(input) {
            return Some(AppError::UsernameNotRespectingRules);
        }

        None
    }
}
