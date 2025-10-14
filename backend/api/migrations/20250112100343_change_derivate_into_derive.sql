-- Add migration script here

ALTER TABLE recovery_codes DROP COLUMN salt_used_to_derivate_key_from_recovery_code;
ALTER TABLE users DROP COLUMN salt_used_to_derivate_key_from_password;

ALTER TABLE recovery_codes ADD COLUMN salt_used_to_derive_key_from_recovery_code TEXT NOT NULL;
ALTER TABLE users ADD COLUMN salt_used_to_derive_key_from_password TEXT;