import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/constants/icons.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/widgets/daily_tracking_carousel_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';

class HabitWidget extends StatelessWidget {
  final Habit habit;
  final HabitParticipation habitParticipation;
  final List<HabitDailyTracking> habitDailyTrackings;

  const HabitWidget({
    Key? key,
    required this.habit,
    required this.habitParticipation,
    required this.habitDailyTrackings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final profileState = context.watch<ProfileBloc>().state;
        final habitState = context.read<HabitBloc>().state;

        if (habitState is HabitsLoaded) {
          final userLocale = profileState.profile!.locale;

          final shortName = getRightTranslationFromJson(
            habit.shortName,
            userLocale,
          );

          final longName = getRightTranslationFromJson(
            habit.longName,
            userLocale,
          );

          // Calculate streak (for simplicity, using a hardcoded value)
          const streak = 100;

          // Define screen size breakpoint
          final bool isLargeScreen = checkIfLargeScreen(context);

          final habitColor =
              AppColorExtension.fromString(habitParticipation.color).color;

          return InkWell(
            onTap: () {
              context.goNamed(
                'habitDetails',
                pathParameters: {'habitId': habit.id},
              );
            },
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Habit icon
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: getIconWidget(
                            iconString: habit.icon,
                            size: 30,
                            color: habitColor,
                          ),
                        ),

                        // Short or Long name based on screen size
                        Expanded(
                          child: Text(
                            isLargeScreen ? longName : shortName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: habitColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // TODO: Day streak + Timer since stop
                    Text(
                      "Day streak: $streak",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    DailyTrackingCarouselWidget(
                      habitId: habit.id,
                      habitDailyTrackings: habitDailyTrackings,
                      habitColor: habitColor,
                      canOpenDayBoxes: false,
                      displayTitle: false,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
