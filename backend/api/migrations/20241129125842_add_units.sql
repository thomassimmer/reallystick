-- Add migration script here

-- Create table for Unit
CREATE TABLE units (
    id UUID PRIMARY KEY,               -- Unique identifier
    short_name TEXT NOT NULL,          -- Short name of the unit
    long_name TEXT NOT NULL,           -- Long name of the unit
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now() -- Timestamp when the unit was created
);

ALTER TABLE habit_daily_trackings DROP COLUMN reset;
ALTER TABLE habit_daily_trackings DROP COLUMN duration;
ALTER TABLE habit_daily_trackings DROP COLUMN unit;
ALTER TABLE habit_daily_trackings DROP COLUMN quantity_per_set;
ALTER TABLE habit_daily_trackings DROP COLUMN quantity_of_set;

ALTER TABLE habit_daily_trackings ADD COLUMN quantity_per_set INTEGER NOT NULL DEFAULT 0;
ALTER TABLE habit_daily_trackings ADD COLUMN quantity_of_set INTEGER NOT NULL DEFAULT 0;
ALTER TABLE habit_daily_trackings ADD COLUMN unit_id UUID NOT NULL;
ALTER TABLE habit_daily_trackings ADD CONSTRAINT fk_unit_tracking FOREIGN KEY (unit_id) REFERENCES units (id) ON DELETE CASCADE;

ALTER TABLE habits ADD COLUMN unit_ids TEXT NOT NULL;          -- List of accepted units for the habit