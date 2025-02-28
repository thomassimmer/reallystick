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
    Key? key,
    required this.habits,
    required this.category,
    required this.habitDailyTrackings,
    required this.habitParticipations,
  }) : super(key: key);

  @override
  SliverList build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final categoryName = getRightTranslationFromJson(
      category.name,
      profileState.profile!.locale,
    );

    //                  Row(
    //   children: [
    //     Padding(
    //         padding: const EdgeInsets.only(right: 16.0),
    //         child: getIconWidget(
    //           iconString: category.icon,
    //           size: 25,
    //           color: context.colors.text,
    //         )),
    //     Expanded(
    //       child: Text(
    //         categoryName,
    //         style: const TextStyle(
    //           fontSize: 18,
    //           fontWeight: FontWeight.w500,
    //         ),
    //       ),
    //     ),
    //   ],
    // ),

// Container(
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey, width: 0.5),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child:

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
