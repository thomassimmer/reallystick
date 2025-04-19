import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/constants/unit_conversion.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/screens/list_daily_trackings_modal.dart';
import 'package:reallystick/features/habits/presentation/widgets/daily_tracking_chart.dart';
import 'package:reallystick/features/habits/presentation/widgets/last_activity_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';

class DailyTrackingCarouselWidget extends StatefulWidget {
  final Habit habit;
  final List<HabitDailyTracking> habitDailyTrackings;
  final Color habitColor;
  final bool canOpenDayBoxes;
  final bool displayTitle;

  DailyTrackingCarouselWidget(
      {super.key,
      required this.habit,
      required this.habitDailyTrackings,
      required this.habitColor,
      required this.canOpenDayBoxes,
      required this.displayTitle});

  @override
  DailyTrackingCarouselWidgetState createState() =>
      DailyTrackingCarouselWidgetState();
}

class DailyTrackingCarouselWidgetState
    extends State<DailyTrackingCarouselWidget> {
  ScrollController scrollController = ScrollController();

  bool showChart = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 50), () {
        _scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    } else {
      Timer(Duration(milliseconds: 400), () => _scrollToBottom());
    }
  }

  void _openDailyTrackings({required DateTime datetime}) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: max(16.0, MediaQuery.of(context).viewInsets.bottom),
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListDailyTrackingsModal(
                  datetime: datetime,
                  habitId: widget.habit.id,
                  habitColor: widget.habitColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final userLocale = profileState.profile!.locale;

    final today = DateTime.now();

    final firstActivity = widget.habitDailyTrackings
      ..sort((a, b) => a.datetime.compareTo(b.datetime));

    final firstDayWithActivity =
        firstActivity.isNotEmpty ? firstActivity.first : null;

    final daysSinceFirstActivity = firstDayWithActivity != null
        ? today.difference(firstDayWithActivity.datetime).inDays
        : 0;

    const dayBoxSize = 30.0;
    final numberOfDays = max(8, daysSinceFirstActivity);

    final lastSunday = today
        .add(Duration(days: DateTime.sunday - today.weekday))
        .copyWith(hour: 1, minute: 0, second: 0);
    DateTime firstMonday = lastSunday
        .subtract(Duration(days: numberOfDays))
        .copyWith(hour: 0, minute: 0, second: 0);
    firstMonday = firstMonday.subtract(Duration(days: firstMonday.weekday - 1));

    final actualNumberOfBoxesToDisplay =
        lastSunday.difference(firstMonday).inDays + 1;

    final lastDays = List.generate(
      actualNumberOfBoxesToDisplay,
      (index) => firstMonday.add(Duration(days: index)),
    );

    final weeks = List.generate(
      (actualNumberOfBoxesToDisplay / 7).ceil(),
      (index) => lastDays.skip(index * 7).take(7).toList(),
    );

    final habitState = context.watch<HabitBloc>().state;

    if (habitState is HabitsLoaded) {
      final Map<DateTime, double> aggregatedQuantities = {
        for (var date in lastDays)
          date: widget.habitDailyTrackings
              .where((tracking) => tracking.datetime.isSameDate(date))
              .fold<double>(
                0.0,
                (sum, tracking) =>
                    sum +
                    normalizeUnit(
                      tracking.quantityOfSet * tracking.quantityPerSet,
                      tracking.unitId,
                      habitState.units,
                    ),
              )
      };

      final maxQuantity = aggregatedQuantities.values.isNotEmpty
          ? aggregatedQuantities.values.reduce((a, b) => a > b ? a : b)
          : 1.0;
      final minQuantity = aggregatedQuantities.values.isNotEmpty
          ? aggregatedQuantities.values.reduce((a, b) => a < b ? a : b)
          : 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.displayTitle)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 20,
                          color: widget.habitColor,
                        ),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.habitDailyTracking,
                          style:
                              TextStyle(fontSize: 20, color: widget.habitColor),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        showChart ? Icons.calendar_month : Icons.query_stats,
                        color: widget.habitColor,
                      ),
                      onPressed: () {
                        setState(() {
                          showChart = !showChart;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                LastActivityWidget(
                  habitDailyTrackings: widget.habitDailyTrackings,
                  userLocale: userLocale,
                ),
                SizedBox(height: 10),
              ],
            ),
          if (showChart) ...[
            DailyTrackingChart(
              aggregatedQuantities: aggregatedQuantities,
              startDate: firstMonday,
              actualNumberOfBoxesToDisplay:
                  today.difference(firstMonday).inDays + 1,
              habitColor: widget.habitColor,
              userLocale: userLocale,
              habit: widget.habit,
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 7; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SizedBox(
                        width: dayBoxSize,
                        child: Center(
                          child: Text(
                            DateFormat('E', userLocale.toString())
                                .format(weeks[0][i]),
                            textAlign: TextAlign.center,
                            style: context.typographies.bodyExtraSmall
                                .copyWith(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: widget.displayTitle ? 150 : 75,
                  width: (dayBoxSize + 8.0) * 7,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: weeks.length,
                    itemBuilder: (context, weekIndex) {
                      final week = weeks[weekIndex];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: week.map(
                            (datetime) {
                              final totalQuantity =
                                  aggregatedQuantities[datetime] ?? 0.0;
                              final normalizedOpacity =
                                  maxQuantity == minQuantity
                                      ? 0.1
                                      : 0.1 +
                                          ((totalQuantity - minQuantity) /
                                              (maxQuantity - minQuantity) *
                                              0.9);
                              final hasActivity =
                                  (aggregatedQuantities[datetime] ?? 0.0) > 0;
                              final border = hasActivity
                                  ? Border.all(
                                      color: widget.habitColor, width: 1)
                                  : null;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: widget.canOpenDayBoxes
                                    ? GestureDetector(
                                        onTap: widget.canOpenDayBoxes
                                            ? () => _openDailyTrackings(
                                                datetime: datetime)
                                            : null,
                                        child: Container(
                                          width: dayBoxSize,
                                          height: dayBoxSize,
                                          decoration: BoxDecoration(
                                            color: widget.habitColor.withValues(
                                                alpha: normalizedOpacity),
                                            border: border,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: dayBoxSize,
                                        height: dayBoxSize,
                                        decoration: BoxDecoration(
                                          color: widget.habitColor.withValues(
                                              alpha: normalizedOpacity),
                                          border: border,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                              );
                            },
                          ).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
