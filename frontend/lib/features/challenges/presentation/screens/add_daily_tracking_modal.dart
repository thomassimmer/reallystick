import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_dropdown_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_button.dart';
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
import 'package:reallystick/i18n/app_localizations.dart';

class AddDailyTrackingModal extends StatefulWidget {
  final String challengeId;

  const AddDailyTrackingModal({required this.challengeId});

  @override
  AddDailyTrackingModalState createState() => AddDailyTrackingModalState();
}

class AddDailyTrackingModalState extends State<AddDailyTrackingModal> {
  String? _selectedHabitId;
  int _selectedDayOfProgram = 0;
  String? _selectedUnitId;
  double? _quantityPerSet;
  int _quantityOfSet = 1;
  int _weight = 0;
  String? _selectedWeightUnitId;
  int _selectedRepeat = 1;
  bool _isRepeatEnabled = false;
  String? _note;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_selectedWeightUnitId == null) {
      // Only initialize if it's not already set
      final habitState = context.watch<HabitBloc>().state;
      final challengeState = context.watch<ChallengeBloc>().state;

      if (habitState is HabitsLoaded && challengeState is ChallengesLoaded) {
        setState(() {
          // Set the last daily tracking params as the initial params
          final lastDailyTrackingsForThisChallenge = challengeState
              .challengeDailyTrackings[widget.challengeId]?.lastOrNull;

          if (lastDailyTrackingsForThisChallenge != null) {
            _selectedHabitId = lastDailyTrackingsForThisChallenge.habitId;
            _selectedUnitId = lastDailyTrackingsForThisChallenge.unitId;
            _selectedWeightUnitId =
                lastDailyTrackingsForThisChallenge.weightUnitId;
          }
          // If not, show kg before other, it's the most used
          else {
            _selectedWeightUnitId = habitState.units.values
                .where((unit) =>
                    getRightTranslationFromJson(unit.shortName, 'en') == 'kg')
                .firstOrNull
                ?.id;
          }
        });
      }
    }
  }

  void addChallengeDailyTracking() {
    final challengeDailyTrackingFormBloc =
        context.read<ChallengeDailyTrackingCreationFormBloc>();

    // Dispatch validation events for all fields
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormHabitChangedEvent(_selectedHabitId),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormDayOfProgramChangedEvent(
          _selectedDayOfProgram),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormQuantityOfSetChangedEvent(
          _quantityOfSet),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormQuantityPerSetChangedEvent(
        _quantityPerSet.toString(),
      ),
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
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormRepeatChangedEvent(_selectedRepeat),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingCreationFormNoteChangedEvent(_note),
    );

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (challengeDailyTrackingFormBloc.state.isValid) {
          final newChallengeDailyTrackingEvent =
              CreateChallengeDailyTrackingEvent(
            challengeId: widget.challengeId,
            dayOfProgram: _selectedDayOfProgram,
            habitId: _selectedHabitId!,
            quantityOfSet: _quantityOfSet,
            quantityPerSet: _quantityPerSet ?? 0,
            unitId: _selectedUnitId!,
            weight: _weight,
            weightUnitId: _selectedWeightUnitId!,
            repeat: _selectedRepeat,
            note: _note,
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
      final challenge = challengeState.challenges[widget.challengeId]!;

      final displayHabitErrorMessage = context.select(
        (ChallengeDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.habitId.displayError;
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

      final displayDayOfProgramErrorMessage = context.select(
        (ChallengeDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.dayOfProgram.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayRepeatErrorMessage = context.select(
        (ChallengeDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.repeat.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayNoteErrorMessage = context.select(
        (ChallengeDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.note.displayError;
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

      final List<String> selectableUnits = (_selectedHabitId != null
          ? habits[_selectedHabitId]!
              .unitIds
              .where((unitId) => units.containsKey(unitId))
              .toList()
          : []);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.addDailyObjective,
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
                    habit.name,
                    userLocale,
                  )),
                );
              },
            ).toList(),
            onChanged: (value) {
              BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(context)
                  .add(ChallengeDailyTrackingCreationFormHabitChangedEvent(
                      value));
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
            errorText: displayHabitErrorMessage,
          ),

          const SizedBox(height: 16),

          if (challenge.startDate != null) ...[
            // Date & Time Selector
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Selector
                Expanded(
                  child: CustomTextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: challenge.startDate!
                            .add(Duration(days: _selectedDayOfProgram)),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDayOfProgram = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            0,
                            0,
                          ).difference(challenge.startDate!).inDays;
                        });
                      }
                      BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(
                              context)
                          .add(
                        ChallengeDailyTrackingCreationFormDayOfProgramChangedEvent(
                            _selectedDayOfProgram),
                      );
                    },
                    labelText: AppLocalizations.of(context)!.date,
                    text: DateFormat.yMMMd(userLocale).format(
                      challenge.startDate!.add(
                        Duration(days: _selectedDayOfProgram),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Day of program selector
            CustomTextField(
              initialValue: (_selectedDayOfProgram + 1).toString(),
              label: AppLocalizations.of(context)!.dayOfProgram,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDayOfProgram = (int.tryParse(value) ?? 1) - 1;
                });
                BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(context)
                    .add(
                  ChallengeDailyTrackingCreationFormDayOfProgramChangedEvent(
                      _selectedDayOfProgram),
                );
              },
            ),
          ],

          const SizedBox(width: 16),

          if (displayDayOfProgramErrorMessage != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
              child: Text(
                displayDayOfProgramErrorMessage,
                style: TextStyle(
                  color: context.colors.error,
                  fontSize: 12.0,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Quantity & Unit Selector
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      _quantityPerSet = double.tryParse(
                        value.replaceAll(',', '.'),
                      );
                    });
                    BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(
                            context)
                        .add(
                      ChallengeDailyTrackingCreationFormQuantityPerSetChangedEvent(
                        value.replaceAll(',', '.'),
                      ),
                    );
                  },
                  errorText: displayQuantityPerSetErrorMessage,
                ),
              ),

              const SizedBox(width: 16),

              // Unit Selector
              Expanded(
                child: CustomDropdownButtonFormField(
                  value: selectableUnits.contains(_selectedUnitId)
                      ? _selectedUnitId
                      : null,
                  items: selectableUnits.map((unitId) {
                    final unit = units[unitId]!;
                    return DropdownMenuItem(
                      value: unitId,
                      child: Text(
                        getRightTranslationForUnitFromJson(
                          unit.longName,
                          _quantityPerSet?.toInt() ?? 0,
                          userLocale,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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

          // Toggle Switch for "Precise Dates"
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.repeatOnMultipleDaysAfter,
              ),
              Switch(
                value: _isRepeatEnabled,
                onChanged: (value) {
                  setState(() {
                    _isRepeatEnabled = value;
                    if (!_isRepeatEnabled) {
                      _selectedRepeat = 1;
                    }
                  });
                },
              ),
            ],
          ),

          if (_isRepeatEnabled) ...[
            // Day of program selector
            CustomTextField(
              initialValue: _selectedRepeat.toString(),
              label: AppLocalizations.of(context)!
                  .numberOfDaysToRepeatThisObjective,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRepeat = int.tryParse(value) ?? 1;
                });
                BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(context)
                    .add(
                  ChallengeDailyTrackingCreationFormRepeatChangedEvent(
                      _selectedRepeat),
                );
              },
              errorText: displayRepeatErrorMessage,
            ),
          ],

          const SizedBox(height: 16),

          CustomTextField(
            initialValue: _note,
            maxLines: null,
            minLines: 3,
            keyboardType: TextInputType.multiline,
            label: AppLocalizations.of(context)!.note,
            onChanged: (value) {
              setState(() {
                _note = value;
              });
              BlocProvider.of<ChallengeDailyTrackingCreationFormBloc>(context)
                  .add(
                ChallengeDailyTrackingCreationFormNoteChangedEvent(_note),
              );
            },
            errorText: displayNoteErrorMessage,
          ),

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
