-- Add migration script here

ALTER TABLE private_messages
DROP CONSTRAINT IF EXISTS private_messages_creator_fkey,
ADD CONSTRAINT private_messages_creator_fkey
FOREIGN KEY (creator) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE habit_daily_trackings
DROP CONSTRAINT IF EXISTS habit_daily_trackings_user_id_fkey,
ADD CONSTRAINT habit_daily_trackings_user_id_fkey
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE habit_participations
DROP CONSTRAINT IF EXISTS habit_participations_user_id_fkey,
ADD CONSTRAINT habit_participations_user_id_fkey
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;