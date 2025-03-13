-- Add migration script here

ALTER TABLE challenge_participations ADD COLUMN reminder_body TEXT;
ALTER TABLE habit_participations ADD COLUMN reminder_body TEXT;