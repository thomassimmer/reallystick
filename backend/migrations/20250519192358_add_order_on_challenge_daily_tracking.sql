-- Add migration script here

ALTER TABLE challenge_daily_trackings ADD COLUMN order_in_day INTEGER NOT NULL DEFAULT 0;
