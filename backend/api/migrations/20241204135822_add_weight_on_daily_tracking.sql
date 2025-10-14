-- Step 1: Add the new columns without a default
ALTER TABLE habit_daily_trackings ADD COLUMN weight INTEGER NOT NULL DEFAULT 0;
ALTER TABLE habit_daily_trackings ADD COLUMN weight_unit_id UUID;

-- Step 2: Ensure the "No unit" entry exists in the `units` table
DO $$
DECLARE
    no_unit_id UUID;
BEGIN
    -- Try to find the ID of the "No unit" entry
    SELECT id INTO no_unit_id FROM units
    WHERE long_name LIKE '%No unit%';

    -- If no such entry exists, insert it
    IF no_unit_id IS NULL THEN
        INSERT INTO units (id, short_name, long_name, created_at)
        VALUES (
            gen_random_uuid(),
            '{"en":"","fr":""}',
            '{"en":{"one":"","other":"No unit"},"fr":{"one":"","other":"Sans unité"}}',
            now()
        )
        RETURNING id INTO no_unit_id;
    END IF;

    -- Step 3: Populate existing rows in `habit_daily_trackings` with the default "No unit" ID
    UPDATE habit_daily_trackings
    SET weight_unit_id = no_unit_id;

    -- Step 4: Make the column NOT NULL
    ALTER TABLE habit_daily_trackings ALTER COLUMN weight_unit_id SET NOT NULL;

    -- Step 5: Add a foreign key constraint
    ALTER TABLE habit_daily_trackings ADD CONSTRAINT fk_weight_unit_tracking FOREIGN KEY (weight_unit_id) REFERENCES units (id) ON DELETE CASCADE;
END $$;