import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class RepeatOnOtherDaysSelectorWithStartDate extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final void Function(Set<int>) onChange;
  final String userLocale;
  final List<ChallengeDailyTracking> challengeDailyTrackings;
  final Color challengeColor;

  const RepeatOnOtherDaysSelectorWithStartDate({
    required this.startDate,
    required this.endDate,
    required this.onChange,
    required this.userLocale,
    required this.challengeDailyTrackings,
    required this.challengeColor,
    super.key,
  });

  @override
  State<RepeatOnOtherDaysSelectorWithStartDate> createState() =>
      _RepeatOnOtherDaysSelectorWithStartDateState();
}

class _RepeatOnOtherDaysSelectorWithStartDateState
    extends State<RepeatOnOtherDaysSelectorWithStartDate> {
  bool _isRepeatEnabled = false;
  final Set<int> daysToRepeatOn = {};

  late final List<List<DateTime>> weeks;

  @override
  void initState() {
    super.initState();
    weeks = _generateWeeks(widget.startDate, widget.endDate);
  }

  List<List<DateTime>> _generateWeeks(DateTime start, DateTime end) {
    DateTime current = start.subtract(Duration(days: start.weekday - 1));
    final lastDay = end;

    List<List<DateTime>> weeks = [];
    while (current.isBefore(lastDay) || current.isSameDate(lastDay)) {
      final week = List.generate(7, (i) => current.add(Duration(days: i)));
      weeks.add(week);
      current = current.add(Duration(days: 7));
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    const double dayBoxSize = 30.0;

    Map<DateTime, List<ChallengeDailyTracking>> challengeDailyTrackingsPerDay =
        {};

    for (var week in weeks) {
      for (var date in week) {
        challengeDailyTrackingsPerDay[date] =
            widget.challengeDailyTrackings.where((tracking) {
          return widget.startDate
              .add(Duration(days: tracking.dayOfProgram))
              .isSameDate(date);
        }).toList();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)!.repeatOnMultipleDaysAfter),
            Switch(
              value: _isRepeatEnabled,
              onChanged: (value) {
                setState(() {
                  _isRepeatEnabled = value;
                  if (!_isRepeatEnabled) daysToRepeatOn.clear();
                });
              },
            ),
          ],
        ),
        if (_isRepeatEnabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 7; i++)
                  SizedBox(
                    width: dayBoxSize + 12.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Center(
                        child: Text(
                          DateFormat('E', widget.userLocale.toString())
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
          Center(
            child: SizedBox(
              height: 40.0 * min(weeks.length, 4),
              width: (dayBoxSize + 12.0) * 7,
              child: ListView.builder(
                itemCount: weeks.length,
                itemBuilder: (context, weekIndex) {
                  final week = weeks[weekIndex];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: week.map(
                        (date) {
                          final isWithinRange =
                              !date.isBefore(widget.startDate) &&
                                  !date.isAfter(widget.endDate);
                          final isSelected = daysToRepeatOn.any(
                            (d) => widget.startDate
                                .add(Duration(days: d))
                                .isSameDate(date),
                          );
                          final numberOfActivitiesOnThatDay =
                              challengeDailyTrackingsPerDay[date]!.length;

                          final dayOfProgram =
                              date.difference(widget.startDate).inDays;

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Column(
                              children: [
                                Text(
                                  date.day.toString(),
                                  style: context.typographies.bodyExtraSmall
                                      .copyWith(
                                    color: isWithinRange
                                        ? Colors.black
                                        : Colors.transparent,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: isWithinRange
                                      ? () {
                                          setState(() {
                                            if (isSelected) {
                                              daysToRepeatOn
                                                  .remove(dayOfProgram);
                                            } else {
                                              daysToRepeatOn.add(dayOfProgram);
                                            }
                                            widget.onChange(daysToRepeatOn);
                                          });
                                        }
                                      : null,
                                  child: Container(
                                    width: dayBoxSize,
                                    height: dayBoxSize,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? widget.challengeColor
                                          : (isWithinRange
                                              ? context.colors.background
                                              : Colors.transparent),
                                      border: Border.all(
                                          width: 0.5,
                                          color: isWithinRange
                                              ? Colors.black
                                              : Colors.transparent),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      numberOfActivitiesOnThatDay.toString(),
                                      style: context.typographies.captionSmall
                                          .copyWith(
                                        color: isWithinRange
                                            ? context.colors.text
                                            : Colors.transparent,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
