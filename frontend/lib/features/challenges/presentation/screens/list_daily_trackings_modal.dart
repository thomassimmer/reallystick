import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
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
import 'package:reallystick/i18n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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

      final challengeColor = AppColorExtension.fromString(
        widget.challengeParticipation != null
            ? widget.challengeParticipation!.color
            : "",
      ).color;

      void markdownTapLinkCallback(
          String text, String? href, String title) async {
        if (href != null) {
          final url = Uri.parse(href);

          if (await canLaunchUrl(url)) {
            await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
              webOnlyWindowName: '_blank',
            );
          }
        }
      }

      ;

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
            ...dailyTrackings.asMap().map(
              (index, dailyTracking) {
                final habit = habitState.habits[dailyTracking.habitId]!;
                final unit = habitState.units[dailyTracking.unitId]!;
                final weightUnit =
                    habitState.units[dailyTracking.weightUnitId]!;

                final shouldDisplaySportSpecificInputsResult =
                    shouldDisplaySportSpecificInputs(
                  habit,
                  habitState.habitCategories,
                );

                final challengeDailyTrackingDate =
                    (widget.challenge.startDate != null
                            ? widget.challenge.startDate!
                            : widget.challengeParticipation != null
                                ? widget.challengeParticipation!.startDate
                                : DateTime.now())
                        .add(Duration(days: dailyTracking.dayOfProgram));

                List<HabitDailyTracking> habitDailyTrackingsOnThatDay =
                    widget.challengeParticipation != null
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

                return MapEntry(
                  index,
                  GestureDetector(
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
                                getRightTranslationFromJson(
                                  habit.name,
                                  userLocale,
                                ),
                                style: context.typographies.body
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              if (dailyTracking.quantityOfSet > 1) ...[
                                Text(
                                  AppLocalizations.of(context)!
                                      .quantityPerSetWithQuantity(
                                          dailyTracking.quantityPerSet),
                                  style: context.typographies.body,
                                ),
                              ] else ...[
                                Text(
                                  AppLocalizations.of(context)!
                                      .quantityWithQuantity(
                                          dailyTracking.quantityPerSet),
                                  style: context.typographies.body,
                                ),
                              ],
                              if (unit.shortName['en'] != '')
                                Text(
                                  " ${getRightTranslationForUnitFromJson(unit.longName, dailyTracking.quantityPerSet, userLocale)}",
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
                                AppLocalizations.of(context)!
                                    .weightWithQuantity(
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
            ).values,
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
