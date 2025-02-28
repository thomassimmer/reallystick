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
  final int icon;
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
  final int icon;
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
  final int icon;
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
