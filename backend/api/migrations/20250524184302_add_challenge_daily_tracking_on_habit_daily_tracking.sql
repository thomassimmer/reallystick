-- Add migration script here

ALTER TABLE habit_daily_trackings
ADD COLUMN challenge_daily_tracking UUID REFERENCES challenge_daily_trackings(id);