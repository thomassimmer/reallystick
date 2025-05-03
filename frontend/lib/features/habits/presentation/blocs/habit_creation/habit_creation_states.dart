import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/habit_category.dart';
import 'package:reallystick/core/validators/habit_description.dart';
import 'package:reallystick/core/validators/habit_name.dart';
import 'package:reallystick/core/validators/icon.dart';
import 'package:reallystick/core/validators/unit.dart';

final class HabitCreationFormState extends Equatable {
  final Map<String, HabitNameValidator> name;
  final Map<String, HabitDescriptionValidator> description;
  final HabitCategoryValidator habitCategory;
  final IconValidator icon;
  final Map<String, UnitValidator> unitIds;
  final bool isValid;
  final String? errorMessage;

  const HabitCreationFormState({
    this.name = const {},
    this.habitCategory = const HabitCategoryValidator.pure(),
    this.icon = const IconValidator.pure(),
    this.description = const {},
    this.unitIds = const {},
    this.isValid = true,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        name,
        icon,
        description,
        habitCategory,
        isValid,
        errorMessage,
        unitIds,
      ];

  HabitCreationFormState copyWith({
    Map<String, HabitNameValidator>? name,
    Map<String, HabitDescriptionValidator>? description,
    HabitCategoryValidator? habitCategory,
    IconValidator? icon,
    Map<String, UnitValidator>? unitIds,
    bool? isValid,
    String? errorMessage,
  }) {
    return HabitCreationFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      habitCategory: habitCategory ?? this.habitCategory,
      icon: icon ?? this.icon,
      unitIds: unitIds ?? this.unitIds,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
