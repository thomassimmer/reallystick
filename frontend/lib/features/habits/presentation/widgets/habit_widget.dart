import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/widgets/daily_tracking_carousel_widget.dart';
import 'package:reallystick/features/habits/presentation/widgets/last_activity_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';

class HabitWidget extends StatelessWidget {
  final Habit habit;
  final HabitParticipation habitParticipation;
  final List<HabitDailyTracking> habitDailyTrackings;

  const HabitWidget({
    super.key,
    required this.habit,
    required this.habitParticipation,
    required this.habitDailyTrackings,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final profileState = context.watch<ProfileBloc>().state;

        final userLocale = profileState.profile!.locale;

        final shortName = getRightTranslationFromJson(
          habit.shortName,
          userLocale,
        );

        final longName = getRightTranslationFromJson(
          habit.longName,
          userLocale,
        );

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
          borderRadius: BorderRadius.circular(10.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Text(
                                  habit.icon,
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                              Text(
                                isLargeScreen ? longName : shortName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: habitColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LastActivityWidget(
                            habitDailyTrackings: habitDailyTrackings,
                            userLocale: userLocale,
                          ),
                        ],
                      ),
                      if (isLargeScreen) ...[
                        Spacer(),
                        DailyTrackingCarouselWidget(
                          habit: habit,
                          habitDailyTrackings: habitDailyTrackings,
                          habitColor: habitColor,
                          canOpenDayBoxes: false,
                          displayTitle: false,
                        ),
                      ],
                    ],
                  ),
                  if (!isLargeScreen) ...[
                    const SizedBox(height: 16),
                    DailyTrackingCarouselWidget(
                      habit: habit,
                      habitDailyTrackings: habitDailyTrackings,
                      habitColor: habitColor,
                      canOpenDayBoxes: false,
                      displayTitle: false,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
