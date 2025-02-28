-- Add migration script here

ALTER TABLE challenges DROP COLUMN end_date;      
ALTER TABLE challenge_daily_trackings DROP COLUMN datetime;      
ALTER TABLE challenge_daily_trackings ADD COLUMN day_of_program INTEGER NOT NULL DEFAULT 0;
