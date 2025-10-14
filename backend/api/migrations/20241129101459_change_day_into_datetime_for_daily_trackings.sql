-- Add migration script here

ALTER TABLE habit_daily_trackings DROP COLUMN day;      
ALTER TABLE habit_daily_trackings ADD COLUMN datetime TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now();
