import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_dropdown_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_button.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_creation/habit_daily_tracking_creation_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_creation/habit_daily_tracking_creation_events.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/helpers/units.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

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
  double? _quantityPerSet;
  int _quantityOfSet = 1;
  int _weight = 0;
  String? _selectedWeightUnitId;

  @override
  void initState() {
    super.initState();

    if (_selectedHabitId == null) {
      // Only initialize if it's not already set

      final habitState = context.read<HabitBloc>().state;

      if (habitState is HabitsLoaded) {
        final habit = habitState.habits[widget.habitId];

        setState(() {
          _selectedHabitId = widget.habitId;

          // Set the last daily tracking unit as the initial unit
          final lastDailyTrackingsForThisHabit = habitState.habitDailyTrackings
              .where((hdt) => hdt.habitId == widget.habitId)
              .lastOrNull;

          if (lastDailyTrackingsForThisHabit != null) {
            _selectedUnitId = lastDailyTrackingsForThisHabit.unitId;
            _selectedWeightUnitId = lastDailyTrackingsForThisHabit.weightUnitId;
          }
          // If not, show minutes before other, it's the most used
          else {
            _selectedUnitId = habit?.unitIds
                    .where((unitId) =>
                        habitState.units.containsKey(unitId) &&
                        getRightTranslationFromJson(
                                habitState.units[unitId]!.shortName, 'en') ==
                            'min')
                    .firstOrNull ??
                habit?.unitIds.first;

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
      HabitDailyTrackingCreationFormQuantityPerSetChangedEvent(
          _quantityPerSet.toString()),
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
            challengeDailyTracking: null,
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

      final habitsUserParticipateIn = habits.values
          .where((habit) => habitState.habitParticipations
              .where((habitParticipation) =>
                  habitParticipation.habitId == habit.id)
              .isNotEmpty)
          .toList();

      habitsUserParticipateIn.sort((a, b) {
        return getRightTranslationFromJson(a.name, userLocale).compareTo(
          getRightTranslationFromJson(b.name, userLocale),
        );
      });

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

      List<String> habitUnits = habits[_selectedHabitId] != null
          ? habits[_selectedHabitId]!
              .unitIds
              .where((unitId) => units.containsKey(unitId))
              .toList()
          : [];

      final Map<String, HabitCategory> habitCategories =
          habitState.habitCategories;

      final Map<String, List<Habit>> groupedHabits = {};
      for (final habit in habitsUserParticipateIn) {
        groupedHabits.putIfAbsent(habit.categoryId, () => []).add(habit);
      }

      // Sort categories by name
      final sortedCategoryIds = groupedHabits.keys.toList()
        ..sort((a, b) {
          final aName = habitCategories[a]?.name.values.first ?? '';
          final bName = habitCategories[b]?.name.values.first ?? '';
          return aName.compareTo(bName);
        });

      // Build dropdown items
      final List<DropdownMenuItem<String>> dropdownItems = [];

      for (final categoryId in sortedCategoryIds) {
        final category = habitCategories[categoryId];
        if (category == null) continue;

        // Add category header (disabled item)
        dropdownItems.add(
          DropdownMenuItem<String>(
            enabled: false,
            child: Text(
              getRightTranslationFromJson(category.name, userLocale),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );

        final sortedHabits = List<Habit>.from(groupedHabits[categoryId]!);
        sortedHabits.sort((a, b) {
          final aName =
              getRightTranslationFromJson(a.name, userLocale).toLowerCase();
          final bName =
              getRightTranslationFromJson(b.name, userLocale).toLowerCase();
          return aName.compareTo(bName);
        });

        for (final habit in sortedHabits) {
          dropdownItems.add(
            DropdownMenuItem<String>(
              value: habit.id,
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        habit.icon,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      getRightTranslationFromJson(habit.name, userLocale),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

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
            items: dropdownItems,
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
                child: CustomTextButton(
                  onPressed: () async {
                    final habitDailyTrackingCreationFormBloc =
                        BlocProvider.of<HabitDailyTrackingCreationFormBloc>(
                            context);

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

                    habitDailyTrackingCreationFormBloc.add(
                      HabitDailyTrackingCreationFormDateTimeChangedEvent(
                        _selectedDateTime,
                      ),
                    );
                  },
                  labelText: AppLocalizations.of(context)!.date,
                  text: DateFormat.yMMMd(userLocale).format(_selectedDateTime),
                ),
              ),

              const SizedBox(width: 16),

              // Time Selector
              Expanded(
                child: CustomTextButton(
                  onPressed: () async {
                    final habitDailyTrackingCreationFormBloc =
                        BlocProvider.of<HabitDailyTrackingCreationFormBloc>(
                            context);

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

                      habitDailyTrackingCreationFormBloc.add(
                        HabitDailyTrackingCreationFormDateTimeChangedEvent(
                          _selectedDateTime,
                        ),
                      );
                    }
                  },
                  labelText: AppLocalizations.of(context)!.time,
                  text: DateFormat.Hm().format(_selectedDateTime),
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
                      _quantityPerSet =
                          double.tryParse(value.replaceAll(',', '.'));
                    });
                    BlocProvider.of<HabitDailyTrackingCreationFormBloc>(context)
                        .add(
                      HabitDailyTrackingCreationFormQuantityPerSetChangedEvent(
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
                  value: _selectedUnitId,
                  items: habitUnits.map((unitId) {
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
