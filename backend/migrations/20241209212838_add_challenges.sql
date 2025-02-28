-- Add migration script here

-- Create table for Challenge
CREATE TABLE challenges (
    id UUID PRIMARY KEY,               -- Unique identifier
    name TEXT NOT NULL,                --  name of the challenge
    description TEXT NOT NULL,                  -- Description of the challenge
    icon TEXT NOT NULL,                -- Icon representing the challenge
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), -- Timestamp when the challenge was created
    start_date TIMESTAMP WITH TIME ZONE, -- Timestamp when the challenge starts
    end_date TIMESTAMP WITH TIME ZONE, -- Timestamp when the challenge ends
    creator UUID NOT NULL,              -- The creator of the challenge
    deleted BOOLEAN NOT NULL DEFAULT FALSE, -- Indicated if the challenge was deleted or not

    CONSTRAINT fk_creator FOREIGN KEY (creator) REFERENCES users (id) ON DELETE CASCADE
);

-- Create table for ChallengeParticipation
CREATE TABLE challenge_participations (
    id UUID PRIMARY KEY,               -- Unique identifier
    user_id UUID NOT NULL,             -- Identifier for the user
    challenge_id UUID NOT NULL,            -- Foreign key to challenges
    color TEXT NOT NULL,               -- Color assigned to the challenge for this user
    start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), -- Timestamp when the user starts the challenge
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), -- Timestamp when the participation was created

    CONSTRAINT fk_challenge FOREIGN KEY (challenge_id) REFERENCES challenges (id) ON DELETE CASCADE,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT unique_challenge_participation_user_pair UNIQUE (challenge_id, user_id)
);

-- Create table for ChallengeDailyTracking
CREATE TABLE challenge_daily_trackings (
    id UUID PRIMARY KEY,               -- Unique identifier
    habit_id UUID NOT NULL,             -- Identifier for the habit
    challenge_id UUID NOT NULL,            -- Foreign key to challenges
    datetime TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), -- Timestamp when the tracking was created

    quantity_of_set INTEGER NOT NULL DEFAULT 0,
    quantity_per_set INTEGER NOT NULL DEFAULT 0,
    unit_id UUID NOT NULL,    -- Unit of measurement
    weight INTEGER NOT NULL DEFAULT 0,
    weight_unit_id UUID NOT NULL,

    CONSTRAINT fk_challenge_tracking FOREIGN KEY (challenge_id) REFERENCES challenges (id) ON DELETE CASCADE,
    CONSTRAINT fk_challenge_tracking_habit FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
    CONSTRAINT fk_unit_tracking FOREIGN KEY (unit_id) REFERENCES units (id) ON DELETE CASCADE,
    CONSTRAINT fk_weight_unit_tracking FOREIGN KEY (weight_unit_id) REFERENCES units (id) ON DELETE CASCADE
);