import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/screens/update_daily_tracking_modal.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class ListDailyTrackingsModal extends StatefulWidget {
  final String habitId;
  final DateTime datetime;

  const ListDailyTrackingsModal({
    Key? key,
    required this.habitId,
    required this.datetime,
  }) : super(key: key);

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
    final habitState = context.watch<HabitBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;

    if (habitState is HabitsLoaded && profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;
      final List<HabitDailyTracking> dailyTrackings = habitState
          .habitDailyTrackings
          .where((hdt) =>
              hdt.habitId == widget.habitId &&
              hdt.datetime.isSameDate(widget.datetime))
          .toList();

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
                final unit = habitState.units[dailyTracking.unitId]!;

                return GestureDetector(
                  onTap: () => _openDailyTrackingUpdateModal(
                    habitDailyTracking: dailyTracking,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Text(
                              DateFormat('HH:mm')
                                  .format(dailyTracking.datetime),
                            ),
                            if (dailyTracking.quantityOfSet > 1) ...[
                              Text(
                                  "     ${AppLocalizations.of(context)!.quantityPerSet} : ${dailyTracking.quantityPerSet}"),
                            ] else ...[
                              Text(
                                  "     ${AppLocalizations.of(context)!.quantity} : ${dailyTracking.quantityPerSet}"),
                            ],
                            if (unit.shortName['en'] != '')
                              Text(
                                  " ${getRightTranslationForUnitFromJson(unit.longName, dailyTracking.quantityPerSet, userLocale)}"),
                            if (dailyTracking.quantityOfSet > 1)
                              Text(
                                  "     ${AppLocalizations.of(context)!.quantityOfSet} : ${dailyTracking.quantityOfSet}"),
                          ],
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
