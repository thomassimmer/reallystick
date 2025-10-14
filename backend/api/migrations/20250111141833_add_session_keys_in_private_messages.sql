-- Add migration script here

ALTER TABLE private_messages ADD COLUMN creator_encrypted_session_key TEXT NOT NULL;
ALTER TABLE private_messages ADD COLUMN recipient_encrypted_session_key TEXT NOT NULL;