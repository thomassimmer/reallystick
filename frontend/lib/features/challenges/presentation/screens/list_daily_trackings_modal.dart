import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/constants/unit_conversion.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/open_url.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/helpers/challenge_result.dart';
import 'package:reallystick/features/challenges/presentation/screens/update_daily_tracking_modal.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/helpers/units.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class ListDailyTrackingsModal extends StatefulWidget {
  final Challenge challenge;
  final ChallengeParticipation? challengeParticipation;
  final DateTime datetime;
  final bool previewMode;

  const ListDailyTrackingsModal({
    super.key,
    required this.challenge,
    required this.challengeParticipation,
    required this.datetime,
    required this.previewMode,
  });

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
            child: Wrap(
              children: [
                UpdateDailyTrackingModal(
                    challengeDailyTracking: challengeDailyTracking),
              ],
            ),
          ),
        );
      },
    );
  }

  void _validateDailyObjective(ChallengeDailyTracking tracking) {
    final now = DateTime.now();
    final event = CreateHabitDailyTrackingEvent(
      datetime: widget.datetime.copyWith(
        hour: now.hour,
        minute: now.minute,
        second: now.second,
      ),
      habitId: tracking.habitId,
      quantityOfSet: tracking.quantityOfSet,
      quantityPerSet: tracking.quantityPerSet,
      unitId: tracking.unitId,
      weight: tracking.weight,
      weightUnitId: tracking.weightUnitId,
      challengeDailyTracking: tracking.id,
    );

    context.read<HabitBloc>().add(event);
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

    if (challengeState is ChallengesLoaded &&
        habitState is HabitsLoaded &&
        profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;

      List<ChallengeDailyTracking> dailyTrackings = challengeState
          .challengeDailyTrackings[widget.challenge.id]!
          .where((tracking) {
        if (widget.challenge.startDate != null) {
          return widget.challenge.startDate!
              .add(Duration(days: tracking.dayOfProgram))
              .isSameDate(widget.datetime);
        }

        if (widget.challengeParticipation != null) {
          return widget.challengeParticipation!.startDate
              .add(Duration(days: tracking.dayOfProgram))
              .isSameDate(widget.datetime);
        }

        return DateTime.now()
            .add(Duration(days: tracking.dayOfProgram))
            .isSameDate(widget.datetime);
      }).toList();

      dailyTrackings.sort((a, b) => a.orderInDay - b.orderInDay);

      final challengeColor = AppColorExtension.fromString(
        widget.challengeParticipation != null
            ? widget.challengeParticipation!.color
            : "",
      ).color;

      final today = DateTime.now();

      List<HabitDailyTracking> habitDailyTrackingsOnThatDay =
          widget.challengeParticipation != null
              ? habitState.habitDailyTrackings
                  .where((hdt) => hdt.datetime.isSameDate(widget.datetime))
                  .toList()
              : [];

      final challengeTrackingAchieved = matchHabitTrackingsToChallengeTrackings(
        dailyTrackings,
        habitDailyTrackingsOnThatDay,
        habitState.units,
      );

      final reorderableElements = dailyTrackings
          .asMap()
          .map(
            (index, dailyTracking) {
              final habit = habitState.habits[dailyTracking.habitId]!;
              final unit = habitState.units[dailyTracking.unitId]!;
              final weightUnit = habitState.units[dailyTracking.weightUnitId]!;

              final shouldDisplaySportSpecificInputsResult =
                  shouldDisplaySportSpecificInputs(
                habit,
                habitState.habitCategories,
              );

              final dailyObjectivesDone =
                  challengeTrackingAchieved[dailyTracking.id] ?? false;

              return MapEntry(
                index,
                GestureDetector(
                  key: Key('$index'),
                  onTap: () {
                    if (widget.challenge.creator == profileState.profile.id) {
                      _openDailyTrackingUpdateModal(
                        challengeDailyTracking: dailyTracking,
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (dailyObjectivesDone) ...[
                                  Icon(
                                    Icons.check,
                                    size: 13,
                                    color: context.colors.success,
                                  ),
                                  SizedBox(width: 10),
                                ],
                                Text(
                                  getRightTranslationFromJson(
                                      habit.name, userLocale),
                                  style: context.typographies.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                if (!dailyObjectivesDone &&
                                    widget.datetime.compareTo(today) <= 0) ...[
                                  ElevatedButton(
                                    onPressed: () =>
                                        _validateDailyObjective(dailyTracking),
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        backgroundColor: context.colors.success,
                                        foregroundColor: Colors.white,
                                        textStyle:
                                            context.typographies.bodySmall,
                                        side: BorderSide(
                                          color: context.colors.background,
                                          width: 1.0,
                                        )),
                                    child: Text(
                                        AppLocalizations.of(context)!.done),
                                  ),
                                  SizedBox(width: 10),
                                ],
                                if (widget.challenge.creator ==
                                    profileState.profile.id)
                                  Icon(Icons.drag_handle),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            if (dailyTracking.quantityOfSet > 1) ...[
                              Text(
                                AppLocalizations.of(context)!
                                    .quantityPerSetWithQuantity(formatQuantity(
                                        dailyTracking.quantityPerSet)),
                                style: context.typographies.body,
                              ),
                            ] else ...[
                              Text(
                                AppLocalizations.of(context)!
                                    .quantityWithQuantity(formatQuantity(
                                        dailyTracking.quantityPerSet)),
                                style: context.typographies.body,
                              ),
                            ],
                            if (unit.shortName['en'] != '')
                              Text(
                                " ${getRightTranslationForUnitFromJson(unit.longName, dailyTracking.quantityPerSet.toInt(), userLocale)}",
                                style: context.typographies.body,
                              ),
                          ],
                        ),
                        if (shouldDisplaySportSpecificInputsResult) ...[
                          if (dailyTracking.quantityOfSet > 1) ...[
                            Text(
                              AppLocalizations.of(context)!
                                  .quantityOfSetWithQuantity(
                                      dailyTracking.quantityOfSet),
                              style: context.typographies.body,
                            ),
                          ],
                          if (weightUnit.shortName['en'] != '' &&
                              dailyTracking.weight > 0) ...[
                            Text(
                              AppLocalizations.of(context)!.weightWithQuantity(
                                  dailyTracking.weight,
                                  getRightTranslationForUnitFromJson(
                                      weightUnit.longName,
                                      dailyTracking.weight,
                                      userLocale)),
                              style: context.typographies.body,
                            ),
                          ],
                        ],
                        if (dailyTracking.note != null &&
                            dailyTracking.note!.isNotEmpty) ...[
                          Text(
                            AppLocalizations.of(context)!.noteWithNote,
                            style: context.typographies.body,
                          ),
                          Markdown(
                            selectable: true,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            data: dailyTracking.note!,
                            onTapLink: markdownTapLinkCallback,
                          ),
                        ],
                        if (index != dailyTrackings.length - 1) ...[
                          SizedBox(height: 10),
                          Divider(color: context.colors.text),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          )
          .values
          .toList();

      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!
                  .allActivitiesOnThisDay(dailyTrackings.length),
              textAlign: TextAlign.center,
              style: context.typographies.headingSmall
                  .copyWith(color: challengeColor),
            ),
            SizedBox(height: 10),
            if (widget.challenge.creator == profileState.profile.id) ...[
              ReorderableListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }

                    final movedItem = dailyTrackings.removeAt(oldIndex);
                    dailyTrackings.insert(newIndex, movedItem);

                    // Define the affected range
                    final start = min(oldIndex, newIndex);
                    final end = max(oldIndex, newIndex);

                    for (int i = start; i <= end; i++) {
                      final cdt = dailyTrackings[i];
                      if (cdt.orderInDay != i) {
                        context.read<ChallengeBloc>().add(
                              UpdateChallengeDailyTrackingEvent(
                                challengeId: cdt.challengeId,
                                habitId: cdt.habitId,
                                dayOfProgram: cdt.dayOfProgram,
                                challengeDailyTrackingId: cdt.id,
                                quantityOfSet: cdt.quantityOfSet,
                                quantityPerSet: cdt.quantityPerSet,
                                unitId: cdt.unitId,
                                weight: cdt.weight,
                                weightUnitId: cdt.weightUnitId,
                                note: cdt.note,
                                daysToRepeatOn: {},
                                orderInDay: i,
                              ),
                            );
                      }
                    }
                  });
                },
                children: reorderableElements,
              )
            ] else ...[
              ...reorderableElements
            ],
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
