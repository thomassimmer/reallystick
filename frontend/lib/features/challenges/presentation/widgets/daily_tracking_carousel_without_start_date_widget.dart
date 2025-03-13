import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/helpers/challenge_result.dart';
import 'package:reallystick/features/challenges/presentation/screens/list_daily_trackings_modal.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class DailyTrackingCarouselWithoutStartDateWidget extends StatefulWidget {
  final String challengeId;
  final List<ChallengeDailyTracking> challengeDailyTrackings;
  final Color challengeColor;
  final bool canOpenDayBoxes;
  final bool displayTitle;

  DailyTrackingCarouselWithoutStartDateWidget(
      {super.key,
      required this.challengeId,
      required this.challengeDailyTrackings,
      required this.challengeColor,
      required this.canOpenDayBoxes,
      required this.displayTitle});

  @override
  DailyTrackingCarouselWithoutStartDateWidgetState createState() =>
      DailyTrackingCarouselWithoutStartDateWidgetState();
}

class DailyTrackingCarouselWithoutStartDateWidgetState
    extends State<DailyTrackingCarouselWithoutStartDateWidget> {
  ScrollController scrollController = ScrollController();
  List<DateTime> lastDays = [];
  double dayBoxSize = 30.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 50), () {
        if (scrollController.hasClients) {
          _scrollToToday();
        }
      });
    });
  }

  void _scrollToToday() {
    final now = DateTime.now();
    final normalizedToday = DateTime(now.year, now.month, now.day);

    final todayIndex =
        lastDays.indexWhere((date) => date.isSameDate(normalizedToday));

    if (todayIndex != -1) {
      double offset =
          (dayBoxSize + 8.0) * (todayIndex ~/ 7); // Scroll to the right week
      scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
            datetime: datetime,
            challengeId: widget.challengeId,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final challengeState = context.watch<ChallengeBloc>().state;
    final habitState = context.watch<HabitBloc>().state;

    if (profileState is ProfileAuthenticated &&
        challengeState is ChallengesLoaded &&
        habitState is HabitsLoaded) {
      final challengeParticipation = challengeState.challengeParticipations
          .where((cp) => cp.challengeId == widget.challengeId)
          .firstOrNull;

      final today = DateTime.now();
      final numberOfDays = (widget.challengeDailyTrackings.isNotEmpty
              ? widget.challengeDailyTrackings
                  .map((cdt) => cdt.dayOfProgram)
                  .reduce(max)
              : 0) +
          1;

      final startDate = challengeParticipation?.startDate ?? today;

      lastDays = List.generate(
        numberOfDays,
        (index) => startDate.add(Duration(days: index)),
      );

      final weeks = List.generate(
        (numberOfDays / 7).ceil(),
        (index) => lastDays.skip(index * 7).take(7).toList(),
      );

      final Map<DateTime, List<ChallengeDailyTracking>>
          challengeDailyTrackingsPerDay = {
        for (var date in lastDays)
          date: widget.challengeDailyTrackings.where((tracking) {
            if (startDate
                .add(Duration(days: tracking.dayOfProgram))
                .isSameDate(date)) {
              return true;
            }

            return false;
          }).toList()
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.displayTitle) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 20,
                  color: widget.challengeColor,
                ),
                SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.challengeDailyTracking,
                  style: TextStyle(
                    fontSize: 20,
                    color: widget.challengeColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
          if (widget.challengeDailyTrackings.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: widget.displayTitle
                      ? 70 * min(weeks.length, 4).toDouble()
                      : 70 * min(weeks.length, 2).toDouble(),
                  width: (dayBoxSize + 8.0) * min(7, numberOfDays),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: weeks.length,
                    itemBuilder: (context, weekIndex) {
                      final week = weeks[weekIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: week.indexed.map(
                            (indexWithDatetime) {
                              int dayIndex = indexWithDatetime.$1;
                              DateTime datetime = indexWithDatetime.$2;

                              bool? dailyObjectivesDone = true;

                              final now = DateTime.now();
                              final normalizedToday = DateTime(
                                now.year,
                                now.month,
                                now.day,
                              );
                              final normalizedDatetime = DateTime(
                                datetime.year,
                                datetime.month,
                                datetime.day,
                              );

                              if (normalizedDatetime.isAfter(normalizedToday)) {
                                dailyObjectivesDone = null;
                              } else {
                                final challengeDailyTrackinsOnThisDate =
                                    challengeDailyTrackingsPerDay[datetime]!;

                                for (final cdt
                                    in challengeDailyTrackinsOnThisDate) {
                                  final challengeDailyTrackingDate = startDate
                                      .add(Duration(days: cdt.dayOfProgram));

                                  List<HabitDailyTracking>
                                      habitDailyTrackingsOnThatDay =
                                      challengeParticipation != null
                                          ? habitState.habitDailyTrackings
                                              .where((hdt) =>
                                                  hdt.datetime.isSameDate(
                                                      challengeDailyTrackingDate) &&
                                                  hdt.habitId == cdt.habitId)
                                              .toList()
                                          : [];

                                  dailyObjectivesDone =
                                      checkIfDailyObjectiveWasDone(
                                    cdt,
                                    habitDailyTrackingsOnThatDay,
                                    habitState.units,
                                  );

                                  if (!dailyObjectivesDone) {
                                    break;
                                  }
                                }
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '${(weekIndex * 7 + dayIndex) + 1}',
                                      textAlign: TextAlign.center,
                                      style: context.typographies.bodyExtraSmall
                                          .copyWith(fontSize: 10),
                                    ),
                                    SizedBox(height: 5),
                                    if (widget.canOpenDayBoxes) ...[
                                      GestureDetector(
                                        onTap: () => _openDailyTrackings(
                                            datetime: datetime),
                                        child: Container(
                                          width: dayBoxSize,
                                          height: dayBoxSize,
                                          decoration: BoxDecoration(
                                            color: widget.challengeColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text(
                                              challengeDailyTrackingsPerDay[
                                                      datetime]!
                                                  .length
                                                  .toString(),
                                              style: context
                                                  .typographies.captionSmall
                                                  .copyWith(
                                                color: Colors.white
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Container(
                                        width: dayBoxSize,
                                        height: dayBoxSize,
                                        decoration: BoxDecoration(
                                          color: widget.challengeColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            challengeDailyTrackingsPerDay[
                                                    datetime]!
                                                .length
                                                .toString(),
                                            style: context
                                                .typographies.captionSmall
                                                .copyWith(
                                              color: Colors.white
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: 5),
                                    if (dailyObjectivesDone != null) ...[
                                      if (dailyObjectivesDone) ...[
                                        Icon(
                                          Icons.check,
                                          size: 13,
                                          color: context.colors.success,
                                        ),
                                      ] else if (normalizedToday
                                          .isSameDate(normalizedDatetime)) ...[
                                        Icon(
                                          Icons.question_mark,
                                          size: 12,
                                          color: context.colors.warning,
                                        ),
                                      ] else ...[
                                        Icon(
                                          Icons.close,
                                          size: 13,
                                          color: context.colors.error,
                                        ),
                                      ]
                                    ]
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
              ],
            ),
          ] else ...[
            Text(AppLocalizations.of(context)!.noChallengeDailyTrackingYet),
          ],
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
