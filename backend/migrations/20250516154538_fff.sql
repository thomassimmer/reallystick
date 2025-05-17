-- Add migration script here
-- Add migration script here

ALTER TABLE private_messages
DROP CONSTRAINT IF EXISTS private_messages_creator_fkey;

ALTER TABLE habit_daily_trackings
DROP CONSTRAINT IF EXISTS habit_daily_trackings_user_id_fkey;

ALTER TABLE habit_participations
DROP CONSTRAINT IF EXISTS habit_participations_user_id_fkey;