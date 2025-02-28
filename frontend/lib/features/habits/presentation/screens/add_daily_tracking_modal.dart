import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_dropdown_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_creation/habit_daily_tracking_creation_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_creation/habit_daily_tracking_creation_events.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/helpers/units.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class AddDailyTrackingModal extends StatefulWidget {
  final String? habitId;

  const AddDailyTrackingModal({this.habitId});

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_selectedHabitId == null) {
      // Only initialize if it's not already set

      final habitState = context.watch<HabitBloc>().state;

      if (habitState is HabitsLoaded) {
        final habit = habitState.habits[widget.habitId];

        setState(() {
          _selectedHabitId = widget.habitId;
          _selectedUnitId = habit?.unitIds
              .where((unitId) => habitState.units.containsKey(unitId))
              .first;
          _selectedWeightUnitId = habitState.units.values
              .where((unit) =>
                  getRightTranslationFromJson(unit.shortName, 'en') == 'kg')
              .firstOrNull
              ?.id;
        });
      }
    }
  }

  void addHabitDailyTracking() {
    final habitDailyTrackingFormBloc =
        context.read<HabitDailyTrackingCreationFormBloc>();

    // Dispatch validation events for all fields
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingCreationFormDateTimeChangedEvent(_selectedDateTime),
    );
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingCreationFormHabitChangedEvent(_selectedHabitId),
    );
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingCreationFormQuantityOfSetChangedEvent(_quantityOfSet),
    );
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingCreationFormQuantityPerSetChangedEvent(_quantityPerSet),
    );
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingCreationFormUnitChangedEvent(_selectedUnitId ?? ""),
    );
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingCreationFormWeightChangedEvent(_weight),
    );
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingCreationFormWeightUnitIdChangedEvent(
          _selectedWeightUnitId ?? ""),
    );

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (habitDailyTrackingFormBloc.state.isValid) {
          final newHabitDailyTrackingEvent = CreateHabitDailyTrackingEvent(
            datetime: _selectedDateTime,
            habitId: _selectedHabitId!,
            quantityOfSet: _quantityOfSet,
            quantityPerSet: _quantityPerSet ?? 0,
            unitId: _selectedUnitId!,
            weight: _weight,
            weightUnitId: _selectedWeightUnitId!,
          );
          if (mounted) {
            context.read<HabitBloc>().add(newHabitDailyTrackingEvent);
            Navigator.of(context).pop();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final habitState = context.watch<HabitBloc>().state;

    if (habitState is HabitsLoaded && profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;

      final habits = habitState.habits;

      final habitsUserParticipateIn = Map.fromEntries(
        habits.values
            .where((habit) => habitState.habitParticipations
                .where((habitParticipation) =>
                    habitParticipation.habitId == habit.id)
                .isNotEmpty)
            .map((habit) => MapEntry(habit.id, habit)),
      );

      final units = habitState.units;

      final displayHabitErrorMessage = context.select(
        (HabitDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.habitId.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayUnitErrorMessage = context.select(
        (HabitDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.unitId.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayQuantityOfSetErrorMessage = context.select(
        (HabitDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.quantityOfSet.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayQuantityPerSetErrorMessage = context.select(
        (HabitDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.quantityPerSet.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayDateTimeErrorMessage = context.select(
        (HabitDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.datetime.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayWeightErrorMessage = context.select(
        (HabitDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.weight.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayWeightUnitErrorMessage = context.select(
        (HabitDailyTrackingCreationFormBloc bloc) {
          final error = bloc.state.weightUnitId.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final shouldDisplaySportSpecificInputsResult =
          shouldDisplaySportSpecificInputs(
              habits[_selectedHabitId], habitState.habitCategories);

      final weightUnits = getWeightUnits(habitState.units);

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
            items: habitsUserParticipateIn.entries.map(
              (entry) {
                final habit = entry.value;
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(getRightTranslationFromJson(
                    habit.longName,
                    userLocale,
                  )), // Adjust to show translated name
                );
              },
            ).toList(),
            onChanged: (value) {
              BlocProvider.of<HabitDailyTrackingCreationFormBloc>(context)
                  .add(HabitDailyTrackingCreationFormHabitChangedEvent(value));
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
                    BlocProvider.of<HabitDailyTrackingCreationFormBloc>(context)
                        .add(HabitDailyTrackingCreationFormDateTimeChangedEvent(
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
                      BlocProvider.of<HabitDailyTrackingCreationFormBloc>(
                              context)
                          .add(
                              HabitDailyTrackingCreationFormDateTimeChangedEvent(
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
                    BlocProvider.of<HabitDailyTrackingCreationFormBloc>(context)
                        .add(
                            HabitDailyTrackingCreationFormQuantityPerSetChangedEvent(
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
                    BlocProvider.of<HabitDailyTrackingCreationFormBloc>(context)
                        .add(
                      HabitDailyTrackingCreationFormUnitChangedEvent(
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

          // Quantity of Sets (only for sport habits, that are not timed)
          if (shouldDisplaySportSpecificInputsResult) ...[
            CustomTextField(
              keyboardType: TextInputType.number,
              label: AppLocalizations.of(context)!.quantityOfSet,
              onChanged: (value) {
                setState(() {
                  _quantityOfSet = int.tryParse(value) ?? 1;
                });
                BlocProvider.of<HabitDailyTrackingCreationFormBloc>(context)
                    .add(
                        HabitDailyTrackingCreationFormQuantityOfSetChangedEvent(
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
                      BlocProvider.of<HabitDailyTrackingCreationFormBloc>(
                              context)
                          .add(HabitDailyTrackingCreationFormWeightChangedEvent(
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
                      BlocProvider.of<HabitDailyTrackingCreationFormBloc>(
                              context)
                          .add(
                        HabitDailyTrackingCreationFormWeightUnitIdChangedEvent(
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
            onPressed: addHabitDailyTracking,
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
