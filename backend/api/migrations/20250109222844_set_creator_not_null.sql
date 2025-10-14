-- Add migration script here

ALTER TABLE private_messages DROP COLUMN discussion_id;
ALTER TABLE private_messages ADD COLUMN discussion_id UUID NOT NULL REFERENCES private_discussions(id) ON DELETE SET NULL;