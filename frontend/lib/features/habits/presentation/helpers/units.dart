import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/domain/entities/unit.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';

List<Unit> getWeightUnits(Map<String, Unit> units) {
  return units.values
      .where((unit) => ['kg', 'g', 'lb']
          .contains(getRightTranslationFromJson(unit.shortName, 'en')))
      .toList();
}

bool shouldDisplaySportSpecificInputs(
    Habit? habit, Map<String, HabitCategory> habitCategories) {
  final sportCategory = habitCategories.values
      .where((habitCategory) =>
          getRightTranslationFromJson(
            habitCategory.name,
            'en',
          ) ==
          'Sport')
      .firstOrNull;

  // We should display sport specific inputs only if category is sport
  // and it's not the "Workout" habit which serves to monitor time doing sport
  return habit != null &&
      sportCategory != null &&
      habitCategories[habit.categoryId] == sportCategory &&
      getRightTranslationFromJson(habit.shortName, 'en') != 'Workout';
}
