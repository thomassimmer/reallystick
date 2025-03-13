import 'dart:collection';

import 'package:equatable/equatable.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

class HabitInitializeEvent extends HabitEvent {}

class CreateHabitEvent extends HabitEvent {
  final String shortName;
  final String longName;
  final String description;
  final String categoryId;
  final String icon;
  final String locale;
  final HashSet<String> unitIds;

  const CreateHabitEvent({
    required this.shortName,
    required this.longName,
    required this.description,
    required this.categoryId,
    required this.icon,
    required this.locale,
    required this.unitIds,
  });

  @override
  List<Object?> get props => [
        shortName,
        longName,
        description,
        categoryId,
        icon,
        locale,
        unitIds,
      ];
}

class UpdateHabitEvent extends HabitEvent {
  final String habitId;
  final Map<String, String> shortName;
  final Map<String, String> longName;
  final Map<String, String> description;
  final String categoryId;
  final String icon;
  final HashSet<String> unitIds;

  const UpdateHabitEvent({
    required this.habitId,
    required this.shortName,
    required this.longName,
    required this.description,
    required this.categoryId,
    required this.icon,
    required this.unitIds,
  });

  @override
  List<Object?> get props => [
        habitId,
        shortName,
        longName,
        description,
        categoryId,
        icon,
        unitIds,
      ];
}

class MergeHabitsEvent extends HabitEvent {
  final String habitToDeleteId;
  final String habitToMergeOnId;
  final Map<String, String> shortName;
  final Map<String, String> longName;
  final Map<String, String> description;
  final String categoryId;
  final String icon;
  final HashSet<String> unitIds;

  const MergeHabitsEvent({
    required this.habitToDeleteId,
    required this.habitToMergeOnId,
    required this.shortName,
    required this.longName,
    required this.description,
    required this.categoryId,
    required this.icon,
    required this.unitIds,
  });

  @override
  List<Object?> get props => [
        habitToDeleteId,
        habitToMergeOnId,
        shortName,
        longName,
        description,
        categoryId,
        icon,
        unitIds,
      ];
}

class CreateHabitDailyTrackingEvent extends HabitEvent {
  final String habitId;
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;

  const CreateHabitDailyTrackingEvent({
    required this.habitId,
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
  });

  @override
  List<Object?> get props => [
        habitId,
        datetime,
        quantityOfSet,
        quantityPerSet,
        unitId,
      ];
}

class UpdateHabitDailyTrackingEvent extends HabitEvent {
  final String habitDailyTrackingId;
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;

  const UpdateHabitDailyTrackingEvent({
    required this.habitDailyTrackingId,
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
  });

  @override
  List<Object?> get props => [
        habitDailyTrackingId,
        datetime,
        quantityOfSet,
        quantityPerSet,
        unitId,
      ];
}

class DeleteHabitDailyTrackingEvent extends HabitEvent {
  final String habitDailyTrackingId;

  const DeleteHabitDailyTrackingEvent({
    required this.habitDailyTrackingId,
  });

  @override
  List<Object?> get props => [
        habitDailyTrackingId,
      ];
}

class CreateHabitParticipationEvent extends HabitEvent {
  final String habitId;

  const CreateHabitParticipationEvent({
    required this.habitId,
  });

  @override
  List<Object?> get props => [
        habitId,
      ];
}

class DeleteHabitParticipationEvent extends HabitEvent {
  final String habitParticipationId;

  const DeleteHabitParticipationEvent({
    required this.habitParticipationId,
  });

  @override
  List<Object?> get props => [
        habitParticipationId,
      ];
}

class UpdateHabitParticipationEvent extends HabitEvent {
  final String habitParticipationId;
  final String color;
  final bool notificationsReminderEnabled;
  final String? reminderTime;
  final String? reminderBody;

  const UpdateHabitParticipationEvent({
    required this.habitParticipationId,
    required this.color,
    required this.notificationsReminderEnabled,
    required this.reminderTime,
    required this.reminderBody,
  });

  @override
  List<Object?> get props => [
        habitParticipationId,
        color,
      ];
}
