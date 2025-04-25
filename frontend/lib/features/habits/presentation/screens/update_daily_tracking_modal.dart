import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_dropdown_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_button.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_update/habit_daily_tracking_update_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_update/habit_daily_tracking_update_events.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/helpers/units.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class UpdateDailyTrackingModal extends StatefulWidget {
  final HabitDailyTracking habitDailyTracking;

  const UpdateDailyTrackingModal({required this.habitDailyTracking});

  @override
  UpdateDailyTrackingModalState createState() =>
      UpdateDailyTrackingModalState();
}

class UpdateDailyTrackingModalState extends State<UpdateDailyTrackingModal> {
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedUnitId;
  int? _quantityPerSet;
  int _quantityOfSet = 1;
  int _weight = 0;
  String? _selectedWeightUnitId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final habitState = context.watch<HabitBloc>().state;

    if (habitState is HabitsLoaded) {
      final weightUnits = getWeightUnits(habitState.units);

      // Set weightUnitId to something else than "No unit" (was set by default during the migration)
      final newSelectedWeightUnitId = weightUnits
              .where(
                  (unit) => unit.id == widget.habitDailyTracking.weightUnitId)
              .firstOrNull
              ?.id ??
          weightUnits
              .where((unit) =>
                  getRightTranslationFromJson(unit.shortName, 'en') == 'kg')
              .firstOrNull
              ?.id;

      setState(() {
        _selectedUnitId = widget.habitDailyTracking.unitId;
        _selectedDateTime = widget.habitDailyTracking.datetime;
        _quantityOfSet = widget.habitDailyTracking.quantityOfSet;
        _quantityPerSet = widget.habitDailyTracking.quantityPerSet;
        _weight = widget.habitDailyTracking.weight;
        _selectedWeightUnitId = newSelectedWeightUnitId;
      });
    }
  }

  void deleteHabitDailyTracking() {
    final deleteHabitDailyTrackingEvent = DeleteHabitDailyTrackingEvent(
        habitDailyTrackingId: widget.habitDailyTracking.id);
    if (mounted) {
      context.read<HabitBloc>().add(deleteHabitDailyTrackingEvent);
      Navigator.of(context).pop();
    }
  }

  void updateHabitDailyTracking() {
    final habitDailyTrackingFormBloc =
        context.read<HabitDailyTrackingUpdateFormBloc>();

    // Dispatch validation events for all fields
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingUpdateFormDateTimeChangedEvent(_selectedDateTime),
    );

    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingUpdateFormQuantityOfSetChangedEvent(_quantityOfSet),
    );
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingUpdateFormQuantityPerSetChangedEvent(_quantityPerSet),
    );
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingUpdateFormUnitChangedEvent(_selectedUnitId ?? ""),
    );
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingUpdateFormWeightChangedEvent(_weight),
    );
    habitDailyTrackingFormBloc.add(
      HabitDailyTrackingUpdateFormWeightUnitIdChangedEvent(
          _selectedWeightUnitId ?? ""),
    );

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (habitDailyTrackingFormBloc.state.isValid) {
          final newHabitDailyTrackingEvent = UpdateHabitDailyTrackingEvent(
            datetime: _selectedDateTime,
            habitDailyTrackingId: widget.habitDailyTracking.id,
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
      final units = habitState.units;

      final displayUnitErrorMessage = context.select(
        (HabitDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.unitId.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayQuantityOfSetErrorMessage = context.select(
        (HabitDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.quantityOfSet.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayQuantityPerSetErrorMessage = context.select(
        (HabitDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.quantityPerSet.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayDateTimeErrorMessage = context.select(
        (HabitDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.datetime.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayWeightErrorMessage = context.select(
        (HabitDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.weight.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final displayWeightUnitErrorMessage = context.select(
        (HabitDailyTrackingUpdateFormBloc bloc) {
          final error = bloc.state.weightUnitId.displayError;
          return error != null
              ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
              : null;
        },
      );

      final habit = habitState.habits[widget.habitDailyTracking.habitId]!;

      final shouldDisplaySportSpecificInputsResult =
          shouldDisplaySportSpecificInputs(habit, habitState.habitCategories);

      final weightUnits = getWeightUnits(habitState.units);

      List<String> habitUnits =
          habits[widget.habitDailyTracking.habitId] != null
              ? habits[widget.habitDailyTracking.habitId]!
                  .unitIds
                  .where((unitId) => units.containsKey(unitId))
                  .toList()
              : [];

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
                AppLocalizations.of(context)!.editActivity,
                textAlign: TextAlign.center,
                style: context.typographies.headingSmall,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date & Time Selector
          Row(
            children: [
              // Day Selector
              Expanded(
                child: CustomTextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(
                        () {
                          _selectedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            _selectedDateTime.hour,
                            _selectedDateTime.minute,
                          );
                        },
                      );
                    }
                    BlocProvider.of<HabitDailyTrackingUpdateFormBloc>(context)
                        .add(
                      HabitDailyTrackingUpdateFormDateTimeChangedEvent(
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
                      BlocProvider.of<HabitDailyTrackingUpdateFormBloc>(context)
                          .add(HabitDailyTrackingUpdateFormDateTimeChangedEvent(
                              _selectedDateTime));
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
                  initialValue: _quantityPerSet.toString(),
                  keyboardType: TextInputType.number,
                  label: shouldDisplaySportSpecificInputsResult
                      ? AppLocalizations.of(context)!.quantityPerSet
                      : AppLocalizations.of(context)!.quantity,
                  onChanged: (value) {
                    setState(() {
                      _quantityPerSet = int.tryParse(value);
                    });
                    BlocProvider.of<HabitDailyTrackingUpdateFormBloc>(context).add(
                        HabitDailyTrackingUpdateFormQuantityPerSetChangedEvent(
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
                  items: habitUnits.map(
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
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnitId = value;
                    });
                    BlocProvider.of<HabitDailyTrackingUpdateFormBloc>(context)
                        .add(HabitDailyTrackingUpdateFormUnitChangedEvent(
                            value ?? ""));
                  },
                  label: AppLocalizations.of(context)!.unit,
                  errorText: displayUnitErrorMessage,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quantity of Sets (only for sport habits)
          if (shouldDisplaySportSpecificInputsResult) ...[
            CustomTextField(
              initialValue: _quantityOfSet.toString(),
              keyboardType: TextInputType.number,
              label: AppLocalizations.of(context)!.quantityOfSet,
              onChanged: (value) {
                setState(() {
                  _quantityOfSet = int.tryParse(value) ?? 1;
                });
                BlocProvider.of<HabitDailyTrackingUpdateFormBloc>(context).add(
                    HabitDailyTrackingUpdateFormQuantityOfSetChangedEvent(
                        int.tryParse(value)));
              },
              errorText: displayQuantityOfSetErrorMessage,
            ),
            const SizedBox(height: 16),
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
                      BlocProvider.of<HabitDailyTrackingUpdateFormBloc>(context)
                          .add(HabitDailyTrackingUpdateFormWeightChangedEvent(
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
                      BlocProvider.of<HabitDailyTrackingUpdateFormBloc>(context)
                          .add(
                        HabitDailyTrackingUpdateFormWeightUnitIdChangedEvent(
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

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: deleteHabitDailyTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.error,
                  ),
                  child: Text(AppLocalizations.of(context)!.delete),
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: updateHabitDailyTracking,
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
