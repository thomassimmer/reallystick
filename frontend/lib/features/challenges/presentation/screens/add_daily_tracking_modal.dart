import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_dropdown_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_creation/challenge_daily_tracking_creation_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_creation/challenge_daily_tracking_creation_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/helpers/units.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class AddDailyTrackingModal extends StatefulWidget {
  final String challengeId;

  const AddDailyTrackingModal({required this.challengeId});

  @override
  AddDailyTrackingModalState createState() => AddDailyTrackingModalState();
}

class AddDailyTrackingModalState extends State<AddDailyTrackingModal> {
  String? _selectedHabitId;
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedUnitId;
  int? _quantityPerSet;
  int _quantityOfSet = 1;
  int _weight = 0;
  String? _selectedWeightUnitId;

  void addChallengeDailyTracking() {
    final challengeDailyTrackingFormBloc =
        context.read<ChallengeDailyTrackingCreationFormBloc>();

    // Dispatch validation events for all fields
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormDateTimeChangedEvent(_selectedDateTime),
    );

    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormQuantityOfSetChangedEvent(
          _quantityOfSet),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormQuantityPerSetChangedEvent(
          _quantityPerSet),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormUnitChangedEvent(_selectedUnitId ?? ""),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormWeightChangedEvent(_weight),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormWeightUnitIdChangedEvent(
          _selectedWeightUnitId ?? ""),
    );

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (challengeDailyTrackingFormBloc.state.isValid) {
          final newChallengeDailyTrackingEvent =
              CreateChallengeDailyTrackingEvent(
            challengeId: widget.challengeId,
            datetime: _selectedDateTime,
            habitId: _selectedHabitId!,
            quantityOfSet: _quantityOfSet,
            quantityPerSet: _quantityPerSet ?? 0,
            unitId: _selectedUnitId!,
            weight: _weight,
            weightUnitId: _selectedWeightUnitId!,
          );
          if (mounted) {
            context.read<ChallengeBloc>().add(newChallengeDailyTrackingEvent);
            Navigator.of(context).pop();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final challengeState = context.watch<ChallengeBloc>().state;
    final habitState = context.watch<HabitBloc>().state;

    if (challengeState is ChallengesLoaded &&
        habitState is HabitsLoaded &&
        profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;

      final habits = habitState.habits;

      final units = habitState.units;

      final displayChallengeErrorMessage = context.select(
        (ChallengeDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.challengeId.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayUnitErrorMessage = context.select(
        (ChallengeDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.unitId.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayQuantityOfSetErrorMessage = context.select(
        (ChallengeDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.quantityOfSet.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayQuantityPerSetErrorMessage = context.select(
        (ChallengeDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.quantityPerSet.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayDateTimeErrorMessage = context.select(
        (ChallengeDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.datetime.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayWeightErrorMessage = context.select(
        (ChallengeDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.weight.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayWeightUnitErrorMessage = context.select(
        (ChallengeDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.weightUnitId.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final shouldDisplaySportSpecificInputsResult =
          shouldDisplaySportSpecificInputs(
              habits[_selectedHabitId], habitState.habitCategories);

      final weightUnits = getWeightUnits(units);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.addActivity,
            textAlign: TextAlign.center,
            style: context.typographies.headingSmall,
          ),

          const SizedBox(height: 16),

          // Habit Selector
          CustomDropdownButtonFormField(
            value: _selectedHabitId,
            items: habits.entries.map(
              (entry) {
                final habit = entry.value;
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(getRightTranslationFromJson(
                    habit.longName,
                    userLocale,
                  )),
                );
              },
            ).toList(),
            onChanged: (value) {
              BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(context)
                  .add(ChallengeDailyTrackingCreationFormHabitChangedEvent(
                      value ?? ""));
              setState(() {
                _selectedHabitId = value;
                _selectedUnitId = _selectedHabitId != null
                    ? habits[_selectedHabitId]!
                        .unitIds
                        .where((unitId) => units.containsKey(unitId))
                        .first
                    : null;
              });
            },
            label: AppLocalizations.of(context)!.habit,
            errorText: displayChallengeErrorMessage,
          ),

          const SizedBox(height: 16),

          // Date & Time Selector
          Row(
            children: [
              // Day Selector
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          _selectedDateTime.hour,
                          _selectedDateTime.minute,
                        );
                      });
                    }
                    BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(
                            context)
                        .add(
                            ChallengeDailyTrackingCreationFormDateTimeChangedEvent(
                                _selectedDateTime));
                  },
                  child: Text(
                    DateFormat.yMMMd().format(_selectedDateTime),
                    style: context.typographies.body,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Time Selector
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          _selectedDateTime.year,
                          _selectedDateTime.month,
                          _selectedDateTime.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                      BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(
                              context)
                          .add(
                              ChallengeDailyTrackingCreationFormDateTimeChangedEvent(
                                  _selectedDateTime));
                    }
                  },
                  child: Text(
                    DateFormat.Hm().format(_selectedDateTime),
                    style: context.typographies.body,
                  ),
                ),
              ),
            ],
          ),

          if (displayDateTimeErrorMessage != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
              child: Text(
                displayDateTimeErrorMessage,
                style: TextStyle(
                  color: context.colors.error,
                  fontSize: 12.0,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Quantity & Unit Selector
          Row(
            children: [
              // Quantity Input
              Expanded(
                child: CustomTextField(
                  keyboardType: TextInputType.number,
                  label: shouldDisplaySportSpecificInputsResult
                      ? AppLocalizations.of(context)!.quantityPerSet
                      : AppLocalizations.of(context)!.quantity,
                  onChanged: (value) {
                    setState(() {
                      _quantityPerSet = int.tryParse(value);
                    });
                    BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(
                            context)
                        .add(
                            ChallengeDailyTrackingCreationFormQuantityPerSetChangedEvent(
                                int.tryParse(value)));
                  },
                  errorText: displayQuantityPerSetErrorMessage,
                ),
              ),

              const SizedBox(width: 16),

              // Unit Selector
              Expanded(
                child: CustomDropdownButtonFormField(
                  value: _selectedUnitId,
                  items: (_selectedHabitId != null
                      ? habits[_selectedHabitId]!
                          .unitIds
                          .where((unitId) => units.containsKey(unitId))
                          .map((unitId) {
                          final unit = units[unitId]!;
                          return DropdownMenuItem(
                            value: unitId,
                            child: Text(
                              getRightTranslationForUnitFromJson(
                                unit.longName,
                                _quantityPerSet ?? 0,
                                userLocale,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList()
                      : []),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnitId = value;
                    });
                    BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(
                            context)
                        .add(
                      ChallengeDailyTrackingCreationFormUnitChangedEvent(
                          value ?? ""),
                    );
                  },
                  label: AppLocalizations.of(context)!.unit,
                  errorText: displayUnitErrorMessage,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quantity of Sets (only for sport challenges, that are not timed)
          if (shouldDisplaySportSpecificInputsResult) ...[
            CustomTextField(
              keyboardType: TextInputType.number,
              label: AppLocalizations.of(context)!.quantityOfSet,
              onChanged: (value) {
                setState(() {
                  _quantityOfSet = int.tryParse(value) ?? 1;
                });
                BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(context)
                    .add(
                        ChallengeDailyTrackingCreationFormQuantityOfSetChangedEvent(
                            int.tryParse(value)));
              },
              errorText: displayQuantityOfSetErrorMessage,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    initialValue: _weight.toString(),
                    keyboardType: TextInputType.number,
                    label: AppLocalizations.of(context)!.weight,
                    onChanged: (value) {
                      setState(() {
                        _weight = int.tryParse(value) ?? 0;
                      });
                      BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(
                              context)
                          .add(
                              ChallengeDailyTrackingCreationFormWeightChangedEvent(
                                  int.tryParse(value) ?? 0));
                    },
                    errorText: displayWeightErrorMessage,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomDropdownButtonFormField(
                    value: _selectedWeightUnitId,
                    items: weightUnits.map((unit) {
                      return DropdownMenuItem(
                        value: unit.id,
                        child: Text(
                          getRightTranslationForUnitFromJson(
                            unit.longName,
                            _weight,
                            userLocale,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWeightUnitId = value;
                      });
                      BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(
                              context)
                          .add(
                        ChallengeDailyTrackingCreationFormWeightUnitIdChangedEvent(
                            value ?? ""),
                      );
                    },
                    label: AppLocalizations.of(context)!.weightUnit,
                    errorText: displayWeightUnitErrorMessage,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Save Button
          ElevatedButton(
            onPressed: addChallengeDailyTracking,
            child: Text(AppLocalizations.of(context)!.save),
          ),

          const SizedBox(height: 16),
        ],
      );
    } else {
      // Show loading or error UI
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
