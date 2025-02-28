import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/habit_category.dart';
import 'package:reallystick/core/validators/habit_description.dart';
import 'package:reallystick/core/validators/habit_icon.dart';
import 'package:reallystick/core/validators/habit_long_name.dart';
import 'package:reallystick/core/validators/habit_short_name.dart';
import 'package:reallystick/core/validators/password.dart';

final class HabitCreationFormState extends Equatable {
  const HabitCreationFormState({
    this.shortName = const HabitShortNameValidator.pure(),
    this.longName = const HabitLongNameValidator.pure(),
    this.habitCategory = const HabitCategoryValidator.pure(),
    this.icon = const HabitIconValidator.pure(),
    this.description = const HabitDescriptionValidator.pure(),
    this.isValid = true,
    this.errorMessage,
  });

  final HabitShortNameValidator shortName;
  final HabitLongNameValidator longName;
  final HabitDescriptionValidator description;
  final HabitCategoryValidator habitCategory;
  final HabitIconValidator icon;
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
      ];

  HabitCreationFormState copyWith({
    HabitShortNameValidator? shortName,
    HabitLongNameValidator? longName,
    HabitDescriptionValidator? description,
    HabitCategoryValidator? habitCategory,
    HabitIconValidator? icon,
    Password? password,
    bool? isValid,
    String? errorMessage,
  }) {
    return HabitCreationFormState(
      shortName: shortName ?? this.shortName,
      longName: longName ?? this.longName,
      description: description ?? this.description,
      habitCategory: habitCategory ?? this.habitCategory,
      icon: icon ?? this.icon,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
