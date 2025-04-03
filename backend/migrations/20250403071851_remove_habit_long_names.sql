-- Add migration script here

ALTER TABLE habits RENAME COLUMN short_name TO name;

ALTER TABLE habits DROP COLUMN long_name;