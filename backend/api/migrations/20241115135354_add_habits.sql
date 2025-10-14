-- Create table for HabitCategory
CREATE TABLE habit_categories (
    id UUID PRIMARY KEY,               -- Unique identifier
    name TEXT NOT NULL,                -- Name of the category
    icon TEXT NOT NULL,                -- Icon representing the category
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now() -- Timestamp when the category was created
);

-- Create table for Habit
CREATE TABLE habits (
    id UUID PRIMARY KEY,               -- Unique identifier
    short_name TEXT NOT NULL,          -- Short name of the habit
    long_name TEXT NOT NULL,           -- Long name of the habit
    category_id UUID NOT NULL,         -- Foreign key to habit_categories
    reviewed BOOLEAN NOT NULL DEFAULT FALSE, -- Indicates if the habit has been reviewed
    description TEXT NOT NULL,                  -- Description of the habit
    icon TEXT NOT NULL,                -- Icon representing the habit
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), -- Timestamp when the habit was created

    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES habit_categories (id) ON DELETE CASCADE
);

-- Create table for HabitParticipation
CREATE TABLE habit_participations (
    id UUID PRIMARY KEY,               -- Unique identifier
    user_id UUID NOT NULL,             -- Identifier for the user
    habit_id UUID NOT NULL,            -- Foreign key to habits
    color TEXT NOT NULL,               -- Color assigned to the habit for this user
    to_gain BOOLEAN NOT NULL DEFAULT FALSE, -- Indicates if the habit is to gain or avoid
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), -- Timestamp when the participation was created

    CONSTRAINT fk_habit FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
);

-- Create table for HabitDailyTracking
CREATE TABLE habit_daily_trackings (
    id UUID PRIMARY KEY,               -- Unique identifier
    user_id UUID NOT NULL,             -- Identifier for the user
    habit_id UUID NOT NULL,            -- Foreign key to habits
    day DATE NOT NULL,                 -- The day the tracking is for
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), -- Timestamp when the tracking was created

    duration INTERVAL,        -- Duration of the activity
    quantity_per_set INTEGER, -- Quantity per set
    quantity_of_set INTEGER,  -- Number of sets
    unit TEXT,                -- Unit of measurement
    reset BOOLEAN NOT NULL DEFAULT FALSE, -- Indicates if the tracking was reset

    CONSTRAINT fk_habit_tracking FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
);