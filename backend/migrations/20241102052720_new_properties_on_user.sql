BEGIN;

ALTER TABLE users
    ADD COLUMN age_category VARCHAR(255),         -- e.g., "young adult", "senior", etc.
    ADD COLUMN gender VARCHAR(50),                -- e.g., "male", "female", "non-binary", etc.
    ADD COLUMN continent VARCHAR(255),            -- e.g., "North America", "Europe", etc.
    ADD COLUMN country VARCHAR(255),              -- e.g., "United States", "France", etc.
    ADD COLUMN region VARCHAR(255),               -- e.g., "Midwest", "Southwest", etc.
    ADD COLUMN activity VARCHAR(255),             -- e.g., "active", "moderate", etc.
    ADD COLUMN financial_situation VARCHAR(255),  -- e.g., "stable", "unstable", etc.
    ADD COLUMN lives_in_urban_area BOOLEAN,       -- true if urban, false if rural
    ADD COLUMN relationship_status VARCHAR(255),  -- e.g., "single", "married", etc.
    ADD COLUMN level_of_education VARCHAR(255),   -- e.g., "high school", "college", etc.
    ADD COLUMN has_children BOOLEAN;              -- true if has children, false if not

COMMIT;