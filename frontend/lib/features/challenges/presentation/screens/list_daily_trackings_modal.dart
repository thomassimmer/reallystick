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
import 'package:reallystick/features/challenges/presentation/screens/update_daily_tracking_modal.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/helpers/units.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class ListDailyTrackingsModal extends StatefulWidget {
  final String challengeId;
  final DateTime datetime;

  const ListDailyTrackingsModal({
    Key? key,
    required this.challengeId,
    required this.datetime,
  }) : super(key: key);

  @override
  ListDailyTrackingsModalState createState() => ListDailyTrackingsModalState();
}

class ListDailyTrackingsModalState extends State<ListDailyTrackingsModal> {
  void _openDailyTrackingUpdateModal({
    required ChallengeDailyTracking challengeDailyTracking,
  }) {
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
          child: Wrap(
            children: [
              UpdateDailyTrackingModal(
                  challengeDailyTracking: challengeDailyTracking),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final challengeState = context.watch<ChallengeBloc>().state;
    final habitState = context.watch<HabitBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;

    if (challengeState is ChallengesLoaded &&
        habitState is HabitsLoaded &&
        profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;
      final challenge = challengeState.challenges[widget.challengeId]!;
      final challengeParticipation = challengeState.challengeParticipations
          .where((cp) => cp.challengeId == widget.challengeId)
          .firstOrNull;

      final List<ChallengeDailyTracking> dailyTrackings = challengeState
          .challengeDailyTrackings[widget.challengeId]!
          .where((tracking) {
        if (challenge.startDate != null) {
          return challenge.startDate!
              .add(Duration(days: tracking.dayOfProgram))
              .isSameDate(widget.datetime);
        }
        if (challengeParticipation != null) {
          return challengeParticipation.startDate
              .add(Duration(days: tracking.dayOfProgram))
              .isSameDate(widget.datetime);
        }
        return DateTime.now()
            .add(Duration(days: tracking.dayOfProgram))
            .isSameDate(widget.datetime);
      }).toList();

      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Wrap(
          children: [
            Text(
              AppLocalizations.of(context)!.allActivitiesOnThisDay,
              textAlign: TextAlign.center,
              style: context.typographies.headingSmall,
            ),
            SizedBox(height: 32),
            ListView.builder(
              shrinkWrap: true,
              itemCount: dailyTrackings.length,
              itemBuilder: (context, index) {
                final dailyTracking = dailyTrackings[index];
                final habit = habitState.habits[dailyTracking.habitId]!;
                final unit = habitState.units[dailyTracking.unitId]!;
                final weightUnit =
                    habitState.units[dailyTracking.weightUnitId]!;

                final shouldDisplaySportSpecificInputsResult =
                    shouldDisplaySportSpecificInputs(
                  habit,
                  habitState.habitCategories,
                );

                final challengeDailyTrackingDate = (challenge.startDate != null
                        ? challenge.startDate!
                        : challengeParticipation != null
                            ? challengeParticipation.startDate
                            : DateTime.now())
                    .add(Duration(days: dailyTracking.dayOfProgram));

                List<HabitDailyTracking> habitDailyTrackingsOnThatDay =
                    challengeParticipation != null
                        ? habitState.habitDailyTrackings
                            .where((hdt) =>
                                hdt.datetime
                                    .isSameDate(challengeDailyTrackingDate) &&
                                hdt.habitId == dailyTracking.habitId)
                            .toList()
                        : [];

                final dailyObjectivesDone = checkIfDailyObjectiveWasDone(
                  dailyTracking,
                  habitDailyTrackingsOnThatDay,
                  habitState.units,
                );

                return GestureDetector(
                  onTap: () => _openDailyTrackingUpdateModal(
                    challengeDailyTracking: dailyTracking,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                if (dailyObjectivesDone) ...[
                                  Icon(
                                    Icons.check,
                                    size: 13,
                                    color: context.colors.success,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                                Text(
                                  "${getRightTranslationFromJson(habit.shortName, userLocale)} - ",
                                  style: context.typographies.bodyLarge,
                                ),
                                if (dailyTracking.quantityOfSet > 1) ...[
                                  Text(
                                    "${AppLocalizations.of(context)!.quantityPerSet} : ${dailyTracking.quantityPerSet}",
                                    style: context.typographies.bodyLarge,
                                  ),
                                ] else ...[
                                  Text(
                                    "${AppLocalizations.of(context)!.quantity} : ${dailyTracking.quantityPerSet}",
                                    style: context.typographies.bodyLarge,
                                  ),
                                ],
                                if (unit.shortName['en'] != '')
                                  Text(
                                    " ${getRightTranslationForUnitFromJson(unit.longName, dailyTracking.quantityPerSet, userLocale)}",
                                    style: context.typographies.bodyLarge,
                                  ),
                                if (shouldDisplaySportSpecificInputsResult) ...[
                                  Text(
                                    "     ${AppLocalizations.of(context)!.quantityOfSet} : ${dailyTracking.quantityOfSet}",
                                    style: context.typographies.bodyLarge,
                                  ),
                                  if (weightUnit.shortName['en'] != '')
                                    Text(
                                      "     ${AppLocalizations.of(context)!.weight} : ${dailyTracking.weight} ${getRightTranslationForUnitFromJson(weightUnit.longName, dailyTracking.weight, userLocale)}",
                                      style: context.typographies.bodyLarge,
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (index != dailyTrackings.length - 1)
                        Divider(color: context.colors.text),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      // TODO
      return SizedBox.shrink();
    }
  }
}
