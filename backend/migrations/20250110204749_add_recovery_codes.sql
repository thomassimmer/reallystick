-- Add migration script here

ALTER TABLE users DROP COLUMN recovery_codes;

CREATE TABLE recovery_codes (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recovery_code TEXT NOT NULL UNIQUE,
    private_key_encrypted TEXT NOT NULL
);