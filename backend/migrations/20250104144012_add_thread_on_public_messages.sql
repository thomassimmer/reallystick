-- Add migration script here

ALTER TABLE public_messages DROP COLUMN thread_id;
ALTER TABLE public_messages ADD COLUMN thread_id UUID NOT NULL REFERENCES public_messages(id) ON DELETE SET NULL;
