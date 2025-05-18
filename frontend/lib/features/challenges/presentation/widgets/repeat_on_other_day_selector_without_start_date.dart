import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class RepeatOnOtherDaysSelectorWithoutStartDate extends StatefulWidget {
  final void Function(Set<int>) onChange;
  final String userLocale;
  final List<ChallengeDailyTracking> challengeDailyTrackings;
  final Color challengeColor;

  const RepeatOnOtherDaysSelectorWithoutStartDate({
    required this.onChange,
    required this.userLocale,
    required this.challengeDailyTrackings,
    required this.challengeColor,
    super.key,
  });

  @override
  State<RepeatOnOtherDaysSelectorWithoutStartDate> createState() =>
      _RepeatOnOtherDaysSelectorWithoutStartDateState();
}

class _RepeatOnOtherDaysSelectorWithoutStartDateState
    extends State<RepeatOnOtherDaysSelectorWithoutStartDate> {
  bool _isRepeatEnabled = false;
  final Set<int> daysToRepeatOn = {};

  late final List<List<DateTime>> weeks;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    weeks = _generateWeeks(today, today.add(Duration(days: 365)));
  }

  List<List<DateTime>> _generateWeeks(DateTime start, DateTime end) {
    DateTime current = start;
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    Map<DateTime, List<ChallengeDailyTracking>> challengeDailyTrackingsPerDay =
        {};

    for (var week in weeks) {
      for (var date in week) {
        challengeDailyTrackingsPerDay[date] =
            widget.challengeDailyTrackings.where((tracking) {
          return today
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
                          final isSelected = daysToRepeatOn.any(
                            (d) => today
                                .add(Duration(days: d))
                                .isSameDate(date),
                          );
                          final numberOfActivitiesOnThatDay =
                              challengeDailyTrackingsPerDay[date]!.length;
                          final dayOfProgram = date.difference(today).inDays;

                          // Problème d'indexation

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Column(
                              children: [
                                Text(
                                  "${dayOfProgram + 1}",
                                  style: context.typographies.bodyExtraSmall,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        daysToRepeatOn.remove(dayOfProgram);
                                      } else {
                                        daysToRepeatOn.add(dayOfProgram);
                                      }
                                      widget.onChange(daysToRepeatOn);
                                    });
                                  },
                                  child: Container(
                                    width: dayBoxSize,
                                    height: dayBoxSize,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? widget.challengeColor
                                          : Colors.grey[200],
                                      border: Border.all(
                                          width: 0.5, color: Colors.black),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      numberOfActivitiesOnThatDay.toString(),
                                      style: context.typographies.captionSmall
                                          .copyWith(
                                        color: context.colors.text,
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
