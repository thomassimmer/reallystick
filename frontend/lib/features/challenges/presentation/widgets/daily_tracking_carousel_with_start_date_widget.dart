import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/helpers/challenge_result.dart';
import 'package:reallystick/features/challenges/presentation/screens/add_daily_tracking_modal.dart';
import 'package:reallystick/features/challenges/presentation/screens/list_daily_trackings_modal.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class DailyTrackingCarouselWithStartDateWidget extends StatefulWidget {
  final ChallengeParticipation? challengeParticipation;
  final Challenge challenge;
  final List<ChallengeDailyTracking> challengeDailyTrackings;
  final Color challengeColor;
  final bool canOpenDayBoxes;
  final bool displayTitle;
  final bool previewMode;

  DailyTrackingCarouselWithStartDateWidget({
    super.key,
    required this.challengeParticipation,
    required this.challenge,
    required this.challengeDailyTrackings,
    required this.challengeColor,
    required this.canOpenDayBoxes,
    required this.displayTitle,
    required this.previewMode,
  });

  @override
  DailyTrackingCarouselWithStartDateWidgetState createState() =>
      DailyTrackingCarouselWithStartDateWidgetState();
}

class DailyTrackingCarouselWithStartDateWidgetState
    extends State<DailyTrackingCarouselWithStartDateWidget> {
  ScrollController scrollController = ScrollController();
  List<DateTime> lastDays = [];
  double dayBoxSize = 30.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Future.delayed(
          Duration(milliseconds: 50),
          () {
            _scrollToToday();
          },
        );
      },
    );
  }

  void _scrollToToday() {
    if (!scrollController.hasClients) {
      Timer(const Duration(milliseconds: 400), _scrollToToday);
      return;
    }

    final now = DateTime.now();
    final normalizedToday = DateTime(now.year, now.month, now.day);

    // Calculate start and end dates
    final numberOfDays = (widget.challengeDailyTrackings.isNotEmpty
            ? widget.challengeDailyTrackings
                .map((cdt) => cdt.dayOfProgram)
                .reduce(max)
            : 0) +
        1;

    final challengeStartDate = widget.challenge.startDate!;
    final endDate = challengeStartDate.add(Duration(days: numberOfDays - 1));

    final firstMonday = challengeStartDate.subtract(
      Duration(days: challengeStartDate.weekday - DateTime.monday),
    );

    final lastSunday = endDate.add(
      Duration(days: DateTime.sunday - endDate.weekday),
    );

    // Compute today's index within `lastDays`
    final todayIndex = normalizedToday.difference(firstMonday).inDays;

    if (todayIndex >= 0 && todayIndex < lastDays.length) {
      final weekIndex = todayIndex ~/ 7;

      final offset = (dayBoxSize + 27) * (weekIndex - 1);
      scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (normalizedToday.isAfter(lastSunday)) {
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
      backgroundColor: context.colors.background,
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListDailyTrackingsModal(
                  datetime: datetime,
                  challenge: widget.challenge,
                  challengeParticipation: widget.challengeParticipation,
                  previewMode: widget.previewMode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDailyTrackingBottomSheet() {
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
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                AddDailyTrackingModal(challengeId: widget.challenge.id)
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = widget.previewMode
        ? getProfileAuthenticatedForPreview(context)
        : context.watch<ProfileBloc>().state;
    final challengeState = widget.previewMode
        ? getChallengeStateForPreview(context)
        : context.watch<ChallengeBloc>().state;
    final habitState = widget.previewMode
        ? getHabitsLoadedForPreview(context)
        : context.watch<HabitBloc>().state;

    if (profileState is ProfileAuthenticated &&
        challengeState is ChallengesLoaded &&
        habitState is HabitsLoaded) {
      final userLocale = profileState.profile.locale;

      final now = DateTime.now();
      final normalizedToday = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final numberOfDays = (widget.challengeDailyTrackings.isNotEmpty
              ? widget.challengeDailyTrackings
                  .map((cdt) => cdt.dayOfProgram)
                  .reduce(max)
              : 0) +
          1;

      final startDate = DateTime(
        widget.challenge.startDate!.year,
        widget.challenge.startDate!.month,
        widget.challenge.startDate!.day,
      );
      final endDate = startDate.add(Duration(days: numberOfDays - 1));

      final firstMonday =
          startDate.subtract(Duration(days: (startDate.weekday - 1)));
      final lastSunday = endDate.add(Duration(days: 7 - endDate.weekday));

      lastDays = List.generate(
        lastSunday.difference(firstMonday).inDays + 1,
        (index) => firstMonday.add(Duration(days: index)),
      );

      final weeks = List.generate(
        (numberOfDays / 7).ceil(),
        (index) => lastDays.skip(index * 7).take(7).toList(),
      );

      final Map<DateTime, List<ChallengeDailyTracking>>
          challengeDailyTrackingsPerDay = {
        for (var date in lastDays)
          date: widget.challengeDailyTrackings.where((tracking) {
            return startDate
                .add(Duration(days: tracking.dayOfProgram))
                .isSameDate(date);
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
                Spacer(),
                if (widget.challenge.creator == profileState.profile.id) ...[
                  InkWell(
                    onTap: _showAddDailyTrackingBottomSheet,
                    child: Icon(
                      Icons.add_outlined,
                      size: 25,
                      color: widget.challengeColor.withValues(alpha: 0.8),
                    ),
                  )
                ],
              ],
            ),
            SizedBox(height: 10),
          ],
          if (widget.challengeDailyTrackings.isNotEmpty) ...[
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
                  height: widget.displayTitle
                      ? 60 * min(weeks.length, 4).toDouble()
                      : 60 * min(weeks.length, 2).toDouble(),
                  width: (dayBoxSize + 8.0) * 7,
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
                          children: week.map(
                            (datetime) {
                              if (datetime.isBefore(startDate) ||
                                  datetime.isAfter(endDate)) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: SizedBox(
                                    width: dayBoxSize,
                                    height: dayBoxSize,
                                  ),
                                );
                              }

                              bool? dailyObjectivesDone;

                              final normalizedDatetime = DateTime(
                                datetime.year,
                                datetime.month,
                                datetime.day,
                              );

                              if (normalizedDatetime
                                          .compareTo(normalizedToday) <=
                                      0 &&
                                  widget.challengeParticipation != null) {
                                final challengeDailyTrackinsOnThisDate =
                                    challengeDailyTrackingsPerDay[datetime]!;

                                for (final cdt
                                    in challengeDailyTrackinsOnThisDate) {
                                  final challengeDailyTrackingDate = startDate
                                      .add(Duration(days: cdt.dayOfProgram));

                                  List<HabitDailyTracking>
                                      habitDailyTrackingsOnThatDay = habitState
                                          .habitDailyTrackings
                                          .where((hdt) =>
                                              hdt.datetime.isSameDate(
                                                  challengeDailyTrackingDate) &&
                                              hdt.habitId == cdt.habitId)
                                          .toList();

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
                              final isToday = datetime.isSameDate(now);
                              final numberOfActivitiesOnThatDay =
                                  challengeDailyTrackingsPerDay[datetime]!
                                      .length;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 5),
                                    if (widget.canOpenDayBoxes) ...[
                                      GestureDetector(
                                        onTap: () => _openDailyTrackings(
                                          datetime: normalizedDatetime,
                                        ),
                                        child: isToday
                                            ? buildCustomBoxForToday(
                                                dayBoxSize,
                                                numberOfActivitiesOnThatDay,
                                              )
                                            : buildCustomBoxForOtherDay(
                                                dayBoxSize,
                                                numberOfActivitiesOnThatDay,
                                              ),
                                      ),
                                    ] else ...[
                                      isToday
                                          ? buildCustomBoxForToday(
                                              dayBoxSize,
                                              numberOfActivitiesOnThatDay,
                                            )
                                          : buildCustomBoxForOtherDay(
                                              dayBoxSize,
                                              numberOfActivitiesOnThatDay,
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
                                    ] else ...[
                                      Icon(
                                        Icons.check,
                                        size: 13,
                                        color: Colors.transparent,
                                      ),
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

  Widget buildCustomBoxForOtherDay(
    double dayBoxSize,
    int numberOfActivitiesOnThatDay,
  ) {
    return Container(
      width: dayBoxSize,
      height: dayBoxSize,
      decoration: BoxDecoration(
        color: widget.challengeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          numberOfActivitiesOnThatDay.toString(),
          style: context.typographies.captionSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget buildCustomBoxForToday(
    double dayBoxSize,
    int numberOfActivitiesOnThatDay,
  ) {
    return Container(
      width: dayBoxSize,
      height: dayBoxSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.transparent),
        gradient: SweepGradient(
          colors: [
            Colors.orange,
            Colors.pink,
            Colors.purple,
            Colors.blue,
            Colors.green,
            Colors.orange,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
          width: dayBoxSize,
          height: dayBoxSize,
          decoration: BoxDecoration(
            color: widget.challengeColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              numberOfActivitiesOnThatDay.toString(),
              style: context.typographies.captionSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
