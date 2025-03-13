import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/features/challenges/presentation/widgets/sliver_app_delegate.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/widgets/habit_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';

class HabitCategoryWidget extends StatelessWidget {
  final Map<String, Habit> habits;
  final HabitCategory category;
  final List<HabitDailyTracking> habitDailyTrackings;
  final List<HabitParticipation> habitParticipations;

  const HabitCategoryWidget({
    super.key,
    required this.habits,
    required this.category,
    required this.habitDailyTrackings,
    required this.habitParticipations,
  });

  @override
  SliverList build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final categoryName = getRightTranslationFromJson(
      category.name,
      profileState.profile!.locale,
    );

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverAppBarDelegate(
              title: categoryName,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final habitParticipation = habitParticipations[index];
                final habit = habits[habitParticipation.habitId]!;
                final habitDailyTrackingsForThisHabit = habitDailyTrackings
                    .where((hdt) => hdt.habitId == habit.id)
                    .toList();

                return HabitWidget(
                  habit: habit,
                  habitParticipation: habitParticipation,
                  habitDailyTrackings: habitDailyTrackingsForThisHabit,
                );
              },
              childCount: habitParticipations.length,
            ),
          )
        ],
      ),
    );
  }
}
