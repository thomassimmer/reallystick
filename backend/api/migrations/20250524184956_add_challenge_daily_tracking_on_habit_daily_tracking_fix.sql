-- Add migration script here

-- 1. Drop the default foreign key constraint
ALTER TABLE habit_daily_trackings
DROP CONSTRAINT IF EXISTS habit_daily_trackings_challenge_daily_tracking_fkey;

-- 2. Add it again with ON DELETE SET NULL
ALTER TABLE habit_daily_trackings
ADD CONSTRAINT fk_challenge_daily_tracking
FOREIGN KEY (challenge_daily_tracking)
REFERENCES challenge_daily_trackings(id)
ON DELETE SET NULL;