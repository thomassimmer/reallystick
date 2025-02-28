import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/habit.dart';
import 'package:reallystick/core/validators/habit_category.dart';
import 'package:reallystick/core/validators/habit_description.dart';
import 'package:reallystick/core/validators/habit_icon.dart';
import 'package:reallystick/core/validators/habit_long_name.dart';
import 'package:reallystick/core/validators/habit_short_name.dart';
import 'package:reallystick/core/validators/password.dart';
import 'package:reallystick/core/validators/unit.dart';

final class HabitMergeFormState extends Equatable {
  const HabitMergeFormState({
    this.habitToMergeOn = const HabitValidator.pure(),
    this.shortName = const {},
    this.longName = const {},
    this.habitCategory = const HabitCategoryValidator.pure(),
    this.icon = const HabitIconValidator.pure(),
    this.description = const {},
    this.unitIds = const {},
    this.isValid = true,
    this.errorMessage,
  });

  final HabitValidator habitToMergeOn;
  final Map<String, HabitShortNameValidator> shortName;
  final Map<String, HabitLongNameValidator> longName;
  final Map<String, HabitDescriptionValidator> description;
  final HabitCategoryValidator habitCategory;
  final HabitIconValidator icon;
  final Map<String, UnitValidator> unitIds;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        habitToMergeOn,
        shortName,
        longName,
        icon,
        description,
        habitCategory,
        unitIds,
        isValid,
        errorMessage,
      ];

  HabitMergeFormState copyWith({
    HabitValidator? habitToMergeOn,
    Map<String, HabitShortNameValidator>? shortName,
    Map<String, HabitLongNameValidator>? longName,
    Map<String, HabitDescriptionValidator>? description,
    HabitCategoryValidator? habitCategory,
    HabitIconValidator? icon,
    Map<String, UnitValidator>? unitIds,
    Password? password,
    bool? isValid,
    String? errorMessage,
  }) {
    return HabitMergeFormState(
      habitToMergeOn: habitToMergeOn ?? this.habitToMergeOn,
      shortName: shortName ?? this.shortName,
      longName: longName ?? this.longName,
      description: description ?? this.description,
      habitCategory: habitCategory ?? this.habitCategory,
      icon: icon ?? this.icon,
      unitIds: unitIds ?? this.unitIds,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
