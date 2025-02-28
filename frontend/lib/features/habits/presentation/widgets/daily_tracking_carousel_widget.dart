import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';

class DailyTrackingCarouselWidget extends StatelessWidget {
  final List<HabitDailyTracking> habitDailyTrackings;
  final Color habitColor;

  DailyTrackingCarouselWidget({
    required this.habitDailyTrackings,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    final profileState = context.watch<ProfileBloc>().state;
    final userLocale = profileState.profile!.locale;

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

    // Ensure the scroll starts at the end
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.bar_chart,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.dailyTracking,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: lastDays.length,
              itemBuilder: (context, index) {
                final date = lastDays[index];
                final dayAbbreviation = DateFormat('E', userLocale.toString())
                    .format(date)
                    .substring(0, 1);
                final isTracked = habitDailyTrackings.any(
                  (tracking) => tracking.datetime.isSameDate(date),
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
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
                          color: isTracked ? habitColor : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
