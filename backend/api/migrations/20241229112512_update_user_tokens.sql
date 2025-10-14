-- Add migration script here

DELETE FROM user_tokens;

ALTER TABLE user_tokens DROP COLUMN token_id;
ALTER TABLE user_tokens ADD COLUMN token_id UUID NOT NULL UNIQUE;
ALTER TABLE user_tokens ADD COLUMN os TEXT;
ALTER TABLE user_tokens ADD COLUMN is_mobile BOOLEAN;
ALTER TABLE user_tokens ADD COLUMN browser TEXT;
ALTER TABLE user_tokens ADD COLUMN app_version TEXT;
ALTER TABLE user_tokens ADD COLUMN model TEXT;



