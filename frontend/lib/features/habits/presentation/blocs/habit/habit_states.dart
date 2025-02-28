import 'package:equatable/equatable.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';

abstract class HabitState extends Equatable {
  final Message? message;

  const HabitState({
    this.message,
  });

  @override
  List<Object?> get props => [message];
}

class HabitsLoading extends HabitState {
  const HabitsLoading({
    super.message,
  });
}

class HabitsFailed extends HabitState {
  const HabitsFailed({
    super.message,
  });
}

class HabitsLoaded extends HabitState {
  final List<HabitParticipation> habitParticipations;
  final Map<String, Habit> habits;
  final List<HabitDailyTracking> habitDailyTrackings;
  final Map<String, HabitCategory> habitCategories;
  final Habit? newlyCreatedHabit;

  const HabitsLoaded({
    super.message,
    required this.habitParticipations,
    required this.habits,
    required this.habitDailyTrackings,
    required this.habitCategories,
    this.newlyCreatedHabit,
  });

  @override
  List<Object?> get props => [
        message,
        habitCategories,
        habitDailyTrackings,
        habitParticipations,
        habits,
        newlyCreatedHabit,
      ];
}
