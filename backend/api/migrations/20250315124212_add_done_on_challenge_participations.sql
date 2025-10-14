-- Add migration script here

ALTER TABLE challenge_participations DROP CONSTRAINT unique_challenge_participation_user_pair;

ALTER TABLE challenge_participations ADD COLUMN finished BOOLEAN NOT NULL DEFAULT FALSE;
