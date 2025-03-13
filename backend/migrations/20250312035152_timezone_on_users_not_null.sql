-- Add migration script here

ALTER TABLE users DROP COLUMN timezone;

ALTER TABLE users ADD COLUMN timezone TEXT NOT NULL DEFAULT '';