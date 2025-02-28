import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/constants/icons.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
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

        // Calculate available screen width and determine how many days to display
        final screenWidth = MediaQuery.of(context).size.width;
        const dayBoxWidth = 25.0; // Fixed width for each datetime box
        const dayBoxSpacing = 10.0; // Spacing between boxes
        final maxBoxes = (screenWidth / (dayBoxWidth + dayBoxSpacing)).floor();

        // Calculate the last days
        final today = DateTime.now();
        final lastDays = List.generate(
          maxBoxes,
          (index) => today.subtract(Duration(days: maxBoxes - 1 - index)),
        );

        final habitColor = getAppColorsFromString(habitParticipation.color);

        return InkWell(
          onTap: () {
            context.pushNamed(
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
                        child: SelectableText(
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

                  // Days tracker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: lastDays.map(
                      (date) {
                        final dayAbbreviation = DateFormat(
                                'E', profileState.profile?.locale ?? 'en')
                            .format(date)
                            .substring(0, 1);
                        final isTracked = habitDailyTrackings.any(
                          (tracking) => tracking.datetime.isSameDate(date),
                        );

                        return Column(
                          children: [
                            Text(
                              dayAbbreviation,
                              style: TextStyle(fontSize: 12),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: dayBoxWidth,
                              height: dayBoxWidth,
                              decoration: BoxDecoration(
                                color:
                                    isTracked ? habitColor : Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
