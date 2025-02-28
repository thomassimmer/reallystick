-- Add migration script here

-- Add unique constraint for the pair (habit_id, user_id)
ALTER TABLE habit_participations
ADD CONSTRAINT unique_habit_user_pair UNIQUE (habit_id, user_id);