-- Add migration script here

CREATE TABLE private_discussions (
    id UUID PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


CREATE TABLE private_messages (
    id UUID PRIMARY KEY,
    discussion_id UUID REFERENCES private_discussions(id) ON DELETE SET NULL,
    creator UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    content TEXT NOT NULL,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    seen BOOLEAN NOT NULL DEFAULT FALSE
);


CREATE TABLE private_discussion_participations (
    id UUID PRIMARY KEY,
    discussion_id UUID NOT NULL REFERENCES private_discussions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    color TEXT NOT NULL,
    has_blocked BOOLEAN NOT NULL DEFAULT FALSE
);

ALTER TABLE users ADD COLUMN private_key_encrypted TEXT;

ALTER TABLE users ADD COLUMN public_key TEXT;
