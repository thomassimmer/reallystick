import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/widgets/habit_category_review_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class AllHabitsScreen extends StatefulWidget {
  @override
  AllHabitsScreenState createState() => AllHabitsScreenState();
}

class AllHabitsScreenState extends State<AllHabitsScreen> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final profileState = context.watch<ProfileBloc>().state;
        final habitState = context.watch<HabitBloc>().state;

        if (profileState is ProfileAuthenticated &&
            habitState is HabitsLoaded) {
          final categories = habitState.habitCategories.values.toList();

          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.allHabits,
                          style: context.typographies.heading,
                        ),
                      ],
                    )),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final habitCategory = categories[index];
                      return HabitCategoryReviewWidget(
                        habits: habitState.habits.values
                            .where(
                                (habit) => habit.categoryId == habitCategory.id)
                            .toList(),
                        category: habitCategory,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
