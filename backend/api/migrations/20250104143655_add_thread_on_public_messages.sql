-- Add migration script here

ALTER TABLE public_messages ADD COLUMN thread_id UUID REFERENCES public_messages(id) ON DELETE SET NULL;