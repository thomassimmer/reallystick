-- Add migration script here

CREATE TABLE public_messages (
    id UUID PRIMARY KEY,
    habit_id UUID REFERENCES habits(id) ON DELETE SET NULL,
    challenge_id UUID REFERENCES challenges(id) ON DELETE SET NULL,
    creator UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    replies_to UUID REFERENCES public_messages(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    content TEXT NOT NULL,
    like_count INT NOT NULL DEFAULT 0,
    deleted_by_creator BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_by_admin BOOLEAN NOT NULL DEFAULT FALSE,
    language_code VARCHAR(2)
);

CREATE TABLE public_message_likes (
    id UUID PRIMARY KEY,
    message_id UUID NOT NULL REFERENCES public_messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (message_id, user_id)
);

CREATE TABLE public_message_reports (
    id UUID PRIMARY KEY,
    message_id UUID NOT NULL REFERENCES public_messages(id) ON DELETE CASCADE,
    reporter UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reason TEXT NOT NULL
);