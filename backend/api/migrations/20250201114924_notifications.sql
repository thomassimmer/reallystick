-- Add migration script here

CREATE TABLE notifications (
    id UUID PRIMARY KEY,               -- Unique identifier
    user_id UUID NOT NULL,             -- Identifier for the user
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), -- Timestamp when the notification was created
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    url TEXT,
    seen BOOLEAN NOT NULL DEFAULT FALSE
);


ALTER TABLE users ADD COLUMN notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN notifications_for_private_messages_enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN notifications_for_public_message_liked_enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN notifications_for_public_message_replies_enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN notifications_user_joined_your_challenge_enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN notifications_user_duplicated_your_challenge_enabled BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE habit_participations ADD COLUMN notifications_reminder_enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE habit_participations ADD COLUMN reminder_time TIME;
ALTER TABLE habit_participations ADD COLUMN timezone TEXT;

ALTER TABLE challenge_participations ADD COLUMN notifications_reminder_enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE challenge_participations ADD COLUMN reminder_time TIME;
ALTER TABLE challenge_participations ADD COLUMN timezone TEXT;
