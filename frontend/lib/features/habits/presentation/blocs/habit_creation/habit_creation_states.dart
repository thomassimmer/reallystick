import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/habit_category.dart';
import 'package:reallystick/core/validators/habit_description.dart';
import 'package:reallystick/core/validators/habit_icon.dart';
import 'package:reallystick/core/validators/habit_long_name.dart';
import 'package:reallystick/core/validators/habit_short_name.dart';
import 'package:reallystick/core/validators/unit.dart';

final class HabitCreationFormState extends Equatable {
  const HabitCreationFormState({
    this.shortName = const HabitShortNameValidator.pure(),
    this.longName = const HabitLongNameValidator.pure(),
    this.habitCategory = const HabitCategoryValidator.pure(),
    this.icon = const HabitIconValidator.pure(),
    this.description = const HabitDescriptionValidator.pure(),
    this.unitIds = const {},
    this.isValid = true,
    this.errorMessage,
  });

  final HabitShortNameValidator shortName;
  final HabitLongNameValidator longName;
  final HabitDescriptionValidator description;
  final HabitCategoryValidator habitCategory;
  final HabitIconValidator icon;
  final Map<String, UnitValidator> unitIds;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        shortName,
        longName,
        icon,
        description,
        habitCategory,
        isValid,
        errorMessage,
        unitIds,
      ];

  HabitCreationFormState copyWith({
    HabitShortNameValidator? shortName,
    HabitLongNameValidator? longName,
    HabitDescriptionValidator? description,
    HabitCategoryValidator? habitCategory,
    HabitIconValidator? icon,
    Map<String, UnitValidator>? unitIds,
    bool? isValid,
    String? errorMessage,
  }) {
    return HabitCreationFormState(
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
