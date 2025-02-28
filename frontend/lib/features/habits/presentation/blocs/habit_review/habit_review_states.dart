import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/description.dart';
import 'package:reallystick/core/validators/habit_category.dart';
import 'package:reallystick/core/validators/habit_long_name.dart';
import 'package:reallystick/core/validators/habit_short_name.dart';
import 'package:reallystick/core/validators/icon.dart';
import 'package:reallystick/core/validators/password.dart';
import 'package:reallystick/core/validators/unit.dart';

final class HabitReviewFormState extends Equatable {
  final Map<String, HabitShortNameValidator> shortName;
  final Map<String, HabitLongNameValidator> longName;
  final Map<String, DescriptionValidator> description;
  final HabitCategoryValidator habitCategory;
  final IconValidator icon;
  final Map<String, UnitValidator> unitIds;
  final bool isValid;
  final String? errorMessage;

  const HabitReviewFormState({
    this.shortName = const {},
    this.longName = const {},
    this.description = const {},
    this.habitCategory = const HabitCategoryValidator.pure(),
    this.icon = const IconValidator.pure(),
    this.unitIds = const {},
    this.isValid = true,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        shortName,
        longName,
        icon,
        description,
        habitCategory,
        unitIds,
        isValid,
        errorMessage,
      ];

  HabitReviewFormState copyWith({
    Map<String, HabitShortNameValidator>? shortName,
    Map<String, HabitLongNameValidator>? longName,
    Map<String, DescriptionValidator>? description,
    HabitCategoryValidator? habitCategory,
    IconValidator? icon,
    Map<String, UnitValidator>? unitIds,
    Password? password,
    bool? isValid,
    String? errorMessage,
  }) {
    return HabitReviewFormState(
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
