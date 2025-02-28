import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
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

class DailyTrackingCarouselWidget extends StatefulWidget {
  final String challengeId;
  final List<ChallengeDailyTracking> challengeDailyTrackings;
  final Color challengeColor;
  final bool canOpenDayBoxes;
  final bool displayTitle;

  DailyTrackingCarouselWidget(
      {Key? key,
      required this.challengeId,
      required this.challengeDailyTrackings,
      required this.challengeColor,
      required this.canOpenDayBoxes,
      required this.displayTitle})
      : super(key: key);

  @override
  DailyTrackingCarouselWidgetState createState() =>
      DailyTrackingCarouselWidgetState();
}

class DailyTrackingCarouselWidgetState
    extends State<DailyTrackingCarouselWidget> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Ensure that the scroll happens after layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the controller has clients and if the scroll position is at the top

      Future.delayed(Duration(milliseconds: 50), () {
        if (widget.challengeDailyTrackings.isNotEmpty &&
            scrollController.hasClients &&
            scrollController.position.minScrollExtent ==
                scrollController.offset) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  @override
  void dispose() {
    // Dispose the scrollController when the widget is disposed
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
        maxWidth: 600,
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
      final userLocale = profileState.profile.locale;
      final challenge = challengeState.challenges[widget.challengeId]!;
      final challengeParticipation = challengeState.challengeParticipations
          .where((cp) => cp.challengeId == widget.challengeId)
          .firstOrNull;

      const dayBoxWidth = 25.0;
      final today = DateTime.now();

      final numberOfDays = (widget.challengeDailyTrackings.isNotEmpty
              ? widget.challengeDailyTrackings
                  .map((cdt) => cdt.dayOfProgram)
                  .reduce(max)
              : 0 // Default value if the list is empty
          ) +
          1;

      final startDate =
          challenge.startDate ?? challengeParticipation?.startDate ?? today;

      // Calculate the last days
      final lastDays = List.generate(
        numberOfDays,
        (index) => startDate.add(Duration(days: index)),
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
                  size: 30,
                  color: widget.challengeColor,
                ),
                SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.challengeDailyTracking,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.challengeColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
          if (challengeParticipation != null) ...[
            SizedBox(height: 10),
            Text(
              "${AppLocalizations.of(context)!.challengeParticipationStartDate} ${DateFormat.yMMMd().format(challengeParticipation.startDate)}",
            ),
            SizedBox(height: 20),
          ],
          if (widget.challengeDailyTrackings.isNotEmpty) ...[
            SizedBox(
              height: 80,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: lastDays.length,
                itemBuilder: (context, index) {
                  final datetime = lastDays[index];
                  final dayAbbreviation = challenge.startDate != null
                      ? DateFormat('Md', userLocale.toString()).format(datetime)
                      : "${index + 1}";

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

                    for (final cdt in challengeDailyTrackinsOnThisDate) {
                      final challengeDailyTrackingDate =
                          startDate.add(Duration(days: cdt.dayOfProgram));

                      List<HabitDailyTracking> habitDailyTrackingsOnThatDay =
                          challengeParticipation != null
                              ? habitState.habitDailyTrackings
                                  .where((hdt) =>
                                      hdt.datetime.isSameDate(
                                          challengeDailyTrackingDate) &&
                                      hdt.habitId == cdt.habitId)
                                  .toList()
                              : [];

                      dailyObjectivesDone = checkIfDailyObjectiveWasDone(
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
                                color: widget.challengeColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  challengeDailyTrackingsPerDay[datetime]!
                                      .length
                                      .toString(),
                                  style: context.typographies.captionSmall
                                      .copyWith(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: dayBoxWidth,
                            height: dayBoxWidth,
                            decoration: BoxDecoration(
                              color: widget.challengeColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                challengeDailyTrackingsPerDay[datetime]!
                                    .length
                                    .toString(),
                                style:
                                    context.typographies.captionSmall.copyWith(
                                  color: Colors.white.withOpacity(0.5),
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
              ),
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
