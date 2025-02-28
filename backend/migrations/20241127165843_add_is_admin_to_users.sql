-- Add migration script here

ALTER TABLE users
ADD COLUMN is_admin BOOL NOT NULL DEFAULT FALSE;
