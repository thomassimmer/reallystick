import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/constants/unit_conversion.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/screens/list_daily_trackings_modal.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';

class DailyTrackingCarouselWidget extends StatefulWidget {
  final String habitId;
  final List<HabitDailyTracking> habitDailyTrackings;
  final Color habitColor;
  final bool canOpenDayBoxes;
  final bool displayTitle;

  DailyTrackingCarouselWidget(
      {Key? key,
      required this.habitId,
      required this.habitDailyTrackings,
      required this.habitColor,
      required this.canOpenDayBoxes,
      required this.displayTitle})
      : super(key: key);

  @override
  DailyTrackingCarouselWidgetState createState() =>
      DailyTrackingCarouselWidgetState();
}

class DailyTrackingCarouselWidgetState
    extends State<DailyTrackingCarouselWidget> {
  void _openDailyTrackings({required DateTime datetime}) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: max(
              16.0,
              MediaQuery.of(context).viewInsets.bottom,
            ),
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: ListDailyTrackingsModal(
              datetime: datetime, habitId: widget.habitId),
        );
      },
    );
  }

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

    final habitState = context.read<HabitBloc>().state;

    if (habitState is HabitsLoaded) {
      // Aggregate total quantities per day in normalized unit (seconds)
      final Map<DateTime, double> aggregatedQuantities = {
        for (var date in lastDays)
          date: widget.habitDailyTrackings
              .where((tracking) => tracking.datetime.isSameDate(date))
              .fold<double>(
                0.0,
                (sum, tracking) =>
                    sum +
                    normalizeUnit(
                      (tracking.quantityOfSet * tracking.quantityPerSet)
                          as double,
                      tracking.unitId,
                      habitState.units,
                    ),
              )
      };

      // Determine the maximum and minimum quantities
      final maxQuantity = aggregatedQuantities.values.isNotEmpty
          ? aggregatedQuantities.values.reduce((a, b) => a > b ? a : b)
          : 1.0;
      final minQuantity = aggregatedQuantities.values.isNotEmpty
          ? aggregatedQuantities.values.reduce((a, b) => a < b ? a : b)
          : 0.0;

      // Ensure the scroll starts at the end
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.displayTitle)
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
              height: 60,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: lastDays.length,
                itemBuilder: (context, index) {
                  final datetime = lastDays[index];
                  final dayAbbreviation = DateFormat('E', userLocale.toString())
                      .format(datetime)
                      .substring(0, 1);

                  final totalQuantity = aggregatedQuantities[datetime] ?? 0.0;

                  // Normalize the opacity
                  final normalizedOpacity = maxQuantity == minQuantity
                      ? 1.0 // Avoid division by zero when all values are equal
                      : 0.1 +
                          ((totalQuantity - minQuantity) /
                              (maxQuantity - minQuantity) *
                              0.9);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          dayAbbreviation,
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        if (widget.canOpenDayBoxes) ...[
                          GestureDetector(
                            onTap: () =>
                                _openDailyTrackings(datetime: datetime),
                            child: Container(
                              width: dayBoxWidth,
                              height: dayBoxWidth,
                              decoration: BoxDecoration(
                                color: widget.habitColor
                                    .withOpacity(normalizedOpacity),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: dayBoxWidth,
                            height: dayBoxWidth,
                            decoration: BoxDecoration(
                              color: widget.habitColor
                                  .withOpacity(normalizedOpacity),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
