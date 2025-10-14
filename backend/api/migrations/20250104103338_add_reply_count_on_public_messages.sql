-- Add migration script here

ALTER TABLE public_messages ADD COLUMN reply_count INT NOT NULL DEFAULT 0;