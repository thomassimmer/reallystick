import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_dropdown_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_update/challenge_daily_tracking_update_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_update/challenge_daily_tracking_update_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/helpers/units.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class UpdateDailyTrackingModal extends StatefulWidget {
  final ChallengeDailyTracking challengeDailyTracking;

  const UpdateDailyTrackingModal({required this.challengeDailyTracking});

  @override
  UpdateDailyTrackingModalState createState() =>
      UpdateDailyTrackingModalState();
}

class UpdateDailyTrackingModalState extends State<UpdateDailyTrackingModal> {
  String? _selectedHabitId;
  int _selectedDayOfProgram = 0;
  String? _selectedUnitId;
  int? _quantityPerSet;
  int _quantityOfSet = 1;
  int _weight = 0;
  String? _selectedWeightUnitId;
  String? _note;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final habitState = context.watch<HabitBloc>().state;

    if (habitState is HabitsLoaded) {
      final weightUnits = getWeightUnits(habitState.units);

      // Set weightUnitId to something else than "No unit" (was set by default during the migration)
      final newSelectedWeightUnitId = weightUnits
              .where((unit) =>
                  unit.id == widget.challengeDailyTracking.weightUnitId)
              .firstOrNull
              ?.id ??
          weightUnits
              .where((unit) =>
                  getRightTranslationFromJson(unit.shortName, 'en') == 'kg')
              .firstOrNull
              ?.id;

      setState(() {
        _selectedHabitId = widget.challengeDailyTracking.habitId;
        _selectedUnitId = widget.challengeDailyTracking.unitId;
        _selectedDayOfProgram = widget.challengeDailyTracking.dayOfProgram;
        _quantityOfSet = widget.challengeDailyTracking.quantityOfSet;
        _quantityPerSet = widget.challengeDailyTracking.quantityPerSet;
        _weight = widget.challengeDailyTracking.weight;
        _selectedWeightUnitId = newSelectedWeightUnitId;
        _note = widget.challengeDailyTracking.note;
      });
    }
  }

  void deleteChallengeDailyTracking() {
    final deleteChallengeDailyTrackingEvent = DeleteChallengeDailyTrackingEvent(
        challengeId: widget.challengeDailyTracking.challengeId,
        challengeDailyTrackingId: widget.challengeDailyTracking.id);
    if (mounted) {
      context.read<ChallengeBloc>().add(deleteChallengeDailyTrackingEvent);
      Navigator.of(context).pop();
    }
  }

  void updateChallengeDailyTracking() {
    final challengeDailyTrackingFormBloc =
        context.read<ChallengeDailyTrackingUpdateFormBloc>();

    // Dispatch validation events for all fields
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingUpdateFormHabitChangedEvent(_selectedHabitId),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingUpdateFormDayOfProgramChangedEvent(
          _selectedDayOfProgram),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingUpdateFormQuantityOfSetChangedEvent(_quantityOfSet),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingUpdateFormQuantityPerSetChangedEvent(
          _quantityPerSet),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingUpdateFormUnitChangedEvent(_selectedUnitId ?? ""),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingUpdateFormWeightChangedEvent(_weight),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingUpdateFormWeightUnitIdChangedEvent(
          _selectedWeightUnitId ?? ""),
    );
    challengeDailyTrackingFormBloc.add(
      ChallengeDailyTrackingUpdateFormNoteChangedEvent(_note),
    );

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (challengeDailyTrackingFormBloc.state.isValid) {
          final newChallengeDailyTrackingEvent =
              UpdateChallengeDailyTrackingEvent(
            challengeId: widget.challengeDailyTracking.challengeId,
            habitId: _selectedHabitId!,
            dayOfProgram: _selectedDayOfProgram,
            challengeDailyTrackingId: widget.challengeDailyTracking.id,
            quantityOfSet: _quantityOfSet,
            quantityPerSet: _quantityPerSet ?? 0,
            unitId: _selectedUnitId!,
            weight: _weight,
            weightUnitId: _selectedWeightUnitId!,
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
      final challenge =
          challengeState.challenges[widget.challengeDailyTracking.challengeId]!;

      final canEdit = challenge.creator == profileState.profile.id;

      final displayHabitErrorMessage = context.select(
        (ChallengeDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.habitId.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayUnitErrorMessage = context.select(
        (ChallengeDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.unitId.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayQuantityOfSetErrorMessage = context.select(
        (ChallengeDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.quantityOfSet.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayQuantityPerSetErrorMessage = context.select(
        (ChallengeDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.quantityPerSet.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayDayOfProgramErrorMessage = context.select(
        (ChallengeDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.dayOfProgram.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayWeightErrorMessage = context.select(
        (ChallengeDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.weight.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayWeightUnitErrorMessage = context.select(
        (ChallengeDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.weightUnitId.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayNoteErrorMessage = context.select(
        (ChallengeDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.note.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final habit = habits[widget.challengeDailyTracking.habitId]!;

      final shouldDisplaySportSpecificInputsResult =
          shouldDisplaySportSpecificInputs(habit, habitState.habitCategories);

      final weightUnits = getWeightUnits(habitState.units);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                splashRadius: 25,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(
                width: 32,
              ),
              Text(
                canEdit
                    ? AppLocalizations.of(context)!.editActivity
                    : AppLocalizations.of(context)!.activity,
                textAlign: TextAlign.center,
                style: context.typographies.headingSmall,
              ),
            ],
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
            onChanged: canEdit
                ? (value) {
                    BlocProvider.of<ChallengeDailyTrackingUpdateFormBloc>(
                            context)
                        .add(ChallengeDailyTrackingUpdateFormHabitChangedEvent(
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
                  }
                : null,
            label: AppLocalizations.of(context)!.habit,
            errorText: displayHabitErrorMessage,
          ),

          const SizedBox(height: 16),

          if (challenge.startDate != null) ...[
            // Date & Time Selector
            Row(
              children: [
                // Day Selector
                Expanded(
                  child: TextButton(
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
                      BlocProvider.of<ChallengeDailyTrackingUpdateFormBloc>(
                              context)
                          .add(
                        ChallengeDailyTrackingUpdateFormDayOfProgramChangedEvent(
                            _selectedDayOfProgram),
                      );
                    },
                    child: Text(
                      DateFormat.yMMMd().format(
                        challenge.startDate!.add(
                          Duration(days: _selectedDayOfProgram),
                        ),
                      ),
                      style: context.typographies.body,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Day of program selector
            CustomTextField(
              initialValue: (_selectedDayOfProgram + 1).toString(),
              enabled: canEdit,
              label: AppLocalizations.of(context)!.dayOfProgram,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDayOfProgram = (int.tryParse(value) ?? 1) - 1;
                });
                BlocProvider.of<ChallengeDailyTrackingUpdateFormBloc>(context)
                    .add(
                  ChallengeDailyTrackingUpdateFormDayOfProgramChangedEvent(
                      _selectedDayOfProgram),
                );
              },
            ),
          ],

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
            children: [
              // Quantity Input
              Expanded(
                child: CustomTextField(
                  enabled: canEdit,
                  initialValue: _quantityPerSet.toString(),
                  keyboardType: TextInputType.number,
                  label: shouldDisplaySportSpecificInputsResult
                      ? AppLocalizations.of(context)!.quantityPerSet
                      : AppLocalizations.of(context)!.quantity,
                  onChanged: (value) {
                    setState(() {
                      _quantityPerSet = int.tryParse(value);
                    });
                    BlocProvider.of<ChallengeDailyTrackingUpdateFormBloc>(
                            context)
                        .add(
                            ChallengeDailyTrackingUpdateFormQuantityPerSetChangedEvent(
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
                  items: habits[widget.challengeDailyTracking.habitId] != null
                      ? habits[widget.challengeDailyTracking.habitId]!
                          .unitIds
                          .where((unitId) => units.containsKey(unitId))
                          .map(
                          (unitId) {
                            final unit = units[unitId]!;
                            return DropdownMenuItem(
                              value: unitId,
                              child: Text(
                                getRightTranslationForUnitFromJson(
                                  unit.longName,
                                  _quantityPerSet ?? 0,
                                  userLocale,
                                ),
                              ),
                            );
                          },
                        ).toList()
                      : [],
                  onChanged: canEdit
                      ? (value) {
                          setState(() {
                            _selectedUnitId = value;
                          });
                          BlocProvider.of<ChallengeDailyTrackingUpdateFormBloc>(
                                  context)
                              .add(
                                  ChallengeDailyTrackingUpdateFormUnitChangedEvent(
                                      value ?? ""));
                        }
                      : null,
                  label: AppLocalizations.of(context)!.unit,
                  errorText: displayUnitErrorMessage,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quantity of Sets (only for sport challenges)
          if (shouldDisplaySportSpecificInputsResult) ...[
            CustomTextField(
              enabled: canEdit,
              initialValue: _quantityOfSet.toString(),
              keyboardType: TextInputType.number,
              label: AppLocalizations.of(context)!.quantityOfSet,
              onChanged: (value) {
                setState(() {
                  _quantityOfSet = int.tryParse(value) ?? 1;
                });
                BlocProvider.of<ChallengeDailyTrackingUpdateFormBloc>(context)
                    .add(
                        ChallengeDailyTrackingUpdateFormQuantityOfSetChangedEvent(
                            int.tryParse(value)));
              },
              errorText: displayQuantityOfSetErrorMessage,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    enabled: canEdit,
                    initialValue: _weight.toString(),
                    keyboardType: TextInputType.number,
                    label: AppLocalizations.of(context)!.weight,
                    onChanged: (value) {
                      setState(() {
                        _weight = int.tryParse(value) ?? 0;
                      });
                      BlocProvider.of<ChallengeDailyTrackingUpdateFormBloc>(
                              context)
                          .add(
                              ChallengeDailyTrackingUpdateFormWeightChangedEvent(
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
                    onChanged: canEdit
                        ? (value) {
                            setState(() {
                              _selectedWeightUnitId = value;
                            });
                            BlocProvider.of<
                                        ChallengeDailyTrackingUpdateFormBloc>(
                                    context)
                                .add(
                              ChallengeDailyTrackingUpdateFormWeightUnitIdChangedEvent(
                                  value ?? ""),
                            );
                          }
                        : null,
                    label: AppLocalizations.of(context)!.weightUnit,
                    errorText: displayWeightUnitErrorMessage,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          CustomTextField(
            initialValue: _note,
            maxLines: null,
            minLines: 3,
            enabled: canEdit,
            keyboardType: TextInputType.multiline,
            label: AppLocalizations.of(context)!.note,
            onChanged: (value) {
              setState(() {
                _note = value;
              });
              BlocProvider.of<ChallengeDailyTrackingUpdateFormBloc>(context)
                  .add(
                ChallengeDailyTrackingUpdateFormNoteChangedEvent(_note),
              );
            },
            errorText: displayNoteErrorMessage,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: deleteChallengeDailyTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.error,
                  ),
                  child: Text(AppLocalizations.of(context)!.delete),
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: updateChallengeDailyTracking,
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ),
            ],
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
