import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/helpers/units.dart';
import 'package:reallystick/features/habits/presentation/screens/update_daily_tracking_modal.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class ListDailyTrackingsModal extends StatefulWidget {
  final String habitId;
  final DateTime datetime;
  final Color habitColor;
  final bool previewMode;

  const ListDailyTrackingsModal({
    super.key,
    required this.habitId,
    required this.datetime,
    required this.habitColor,
    required this.previewMode,
  });

  @override
  ListDailyTrackingsModalState createState() => ListDailyTrackingsModalState();
}

class ListDailyTrackingsModalState extends State<ListDailyTrackingsModal> {
  void _openDailyTrackingUpdateModal({
    required HabitDailyTracking habitDailyTracking,
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
              UpdateDailyTrackingModal(habitDailyTracking: habitDailyTracking),
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
    final habitState = widget.previewMode
        ? getHabitsLoadedForPreview(context)
        : context.watch<HabitBloc>().state;

    if (habitState is HabitsLoaded && profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;
      final List<HabitDailyTracking> dailyTrackings = habitState
          .habitDailyTrackings
          .where((hdt) =>
              hdt.habitId == widget.habitId &&
              hdt.datetime.isSameDate(widget.datetime))
          .toList();
      final habit = habitState.habits[widget.habitId];

      dailyTrackings.sort((a, b) => a.datetime.compareTo(b.datetime));

      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .allActivitiesOnThisDay(dailyTrackings.length),
              textAlign: TextAlign.center,
              style: context.typographies.headingSmall
                  .copyWith(color: widget.habitColor),
            ),
            SizedBox(height: 10),
            ...dailyTrackings.asMap().map(
              (index, dailyTracking) {
                final unit = habitState.units[dailyTracking.unitId]!;
                final weightUnit =
                    habitState.units[dailyTracking.weightUnitId]!;

                final shouldDisplaySportSpecificInputsResult =
                    shouldDisplaySportSpecificInputs(
                        habit, habitState.habitCategories);

                return MapEntry(
                  index,
                  GestureDetector(
                    onTap: () => _openDailyTrackingUpdateModal(
                      habitDailyTracking: dailyTracking,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.timeWithTime(
                                DateFormat('HH:mm')
                                    .format(dailyTracking.datetime)),
                            style: context.typographies.body,
                          ),
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
                                dailyTracking.weight > 0)
                              Text(
                                AppLocalizations.of(context)!
                                    .weightWithQuantity(
                                  dailyTracking.weight,
                                  getRightTranslationForUnitFromJson(
                                      weightUnit.longName,
                                      dailyTracking.weight,
                                      userLocale),
                                ),
                                style: context.typographies.body,
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
