-- Add migration script here
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMPTZ;