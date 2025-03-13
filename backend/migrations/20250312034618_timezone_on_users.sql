-- Add migration script here

ALTER TABLE habit_participations DROP COLUMN timezone;
ALTER TABLE challenge_participations DROP COLUMN timezone;

ALTER TABLE users ADD COLUMN timezone TEXT;