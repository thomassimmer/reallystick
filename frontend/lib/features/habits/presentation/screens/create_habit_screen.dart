import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_dropdown_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/custom_elevated_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/presentation/widgets/multi_unit_select_dropdown.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_creation/habit_creation_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_creation/habit_creation_events.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class CreateHabitScreen extends StatefulWidget {
  @override
  CreateHabitScreenState createState() => CreateHabitScreenState();
}

class CreateHabitScreenState extends State<CreateHabitScreen> {
  final TextEditingController _shortNameController = TextEditingController();
  final TextEditingController _longNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategoryId;
  IconData? _icon;
  HashSet<String> _selectedUnitIds = HashSet();

  _pickIcon() async {
    IconPickerIcon? icon = await showIconPicker(
      context,
      configuration: SinglePickerConfiguration(
        iconPackModes: [IconPack.material],
      ),
    );

    if (mounted) {
      BlocProvider.of<HabitCreationFormBloc>(context).add(
        HabitCreationFormIconChangedEvent(
            icon != null ? icon.data.codePoint.toString() : ""),
      );
    }

    setState(() {
      _icon = icon?.data;
    });
  }

  void _createHabit(String locale) {
    final habitFormBloc = context.read<HabitCreationFormBloc>();

    // Dispatch validation events for all fields
    habitFormBloc
        .add(HabitCreationFormCategoryChangedEvent(_selectedCategoryId ?? ""));
    habitFormBloc
        .add(HabitCreationFormShortNameChangedEvent(_shortNameController.text));
    habitFormBloc
        .add(HabitCreationFormLongNameChangedEvent(_longNameController.text));
    habitFormBloc.add(
        HabitCreationFormDescriptionChangedEvent(_descriptionController.text));
    habitFormBloc.add(HabitCreationFormIconChangedEvent(
        _icon != null ? _icon!.codePoint.toString() : ""));

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (habitFormBloc.state.isValid) {
          final newHabitEvent = CreateHabitEvent(
            shortName: _shortNameController.text,
            longName: _longNameController.text,
            description: _descriptionController.text,
            categoryId: _selectedCategoryId ?? "",
            icon: _icon?.codePoint ?? 0,
            locale: locale,
            unitIds: _selectedUnitIds,
          );

          if (mounted) {
            context.read<HabitBloc>().add(newHabitEvent);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final habitState = context.watch<HabitBloc>().state;

    return BlocListener<HabitBloc, HabitState>(
      listener: (context, state) {
        if (state is HabitsLoaded && state.message is SuccessMessage) {
          final message = state.message as SuccessMessage;

          if (message.messageKey == "habitCreated") {
            final newHabit = state.newlyCreatedHabit;

            if (newHabit != null) {
              context.goNamed(
                'habitDetails',
                pathParameters: {'habitId': newHabit.id},
              );
            }
          }
        }
      },
      child: Builder(
        builder: (context) {
          if (profileState is ProfileAuthenticated &&
              habitState is HabitsLoaded) {
            final userLocale = profileState.profile.locale;
            final Map<String, HabitCategory> habitCategories =
                habitState.habitCategories;

            final displayHabitCategoryError = context.select(
              (HabitCreationFormBloc habitCreationFormBloc) =>
                  habitCreationFormBloc.state.habitCategory.displayError,
            );
            final displayHabitCategoryErrorMessage =
                displayHabitCategoryError != null
                    ? getTranslatedMessage(context,
                        ErrorMessage(displayHabitCategoryError.messageKey))
                    : null;

            final displayShortNameError = context.select(
              (HabitCreationFormBloc habitCreationFormBloc) =>
                  habitCreationFormBloc.state.shortName.displayError,
            );
            final displayShortNameErrorMessage = displayShortNameError != null
                ? getTranslatedMessage(
                    context, ErrorMessage(displayShortNameError.messageKey))
                : null;

            final displayLongNameError = context.select(
              (HabitCreationFormBloc habitCreationFormBloc) =>
                  habitCreationFormBloc.state.longName.displayError,
            );
            final displayLongNameErrorMessage = displayLongNameError != null
                ? getTranslatedMessage(
                    context, ErrorMessage(displayLongNameError.messageKey))
                : null;

            final displayDescriptionError = context.select(
              (HabitCreationFormBloc habitCreationFormBloc) =>
                  habitCreationFormBloc.state.description.displayError,
            );
            final displayDescriptionErrorMessage = displayDescriptionError !=
                    null
                ? getTranslatedMessage(
                    context, ErrorMessage(displayDescriptionError.messageKey))
                : null;

            final displayIconError = context.select(
              (HabitCreationFormBloc habitCreationFormBloc) =>
                  habitCreationFormBloc.state.icon.displayError,
            );
            final displayIconErrorMessage = displayIconError != null
                ? getTranslatedMessage(
                    context, ErrorMessage(displayIconError.messageKey))
                : null;

            final unitsErrorMap = context.select(
              (HabitCreationFormBloc habitCreationFormBloc) =>
                  habitCreationFormBloc.state.unitIds.values
                      .map((validator) => validator.displayError != null
                          ? getTranslatedMessage(
                              context,
                              ErrorMessage(validator.displayError!.messageKey),
                            )
                          : '')
                      .where((error) => error.isNotEmpty)
                      .toList(),
            );

            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.addNewHabit),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Category Selector
                          CustomDropdownButtonFormField(
                            value: _selectedCategoryId,
                            items: habitCategories.entries
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(
                                      getRightTranslationFromJson(
                                        entry.value.name,
                                        userLocale,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              BlocProvider.of<HabitCreationFormBloc>(context)
                                  .add(HabitCreationFormCategoryChangedEvent(
                                      value ?? ""));
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                            label: AppLocalizations.of(context)!.category,
                            errorText: displayHabitCategoryErrorMessage,
                          ),

                          const SizedBox(height: 16.0),

                          // Short Name Input
                          CustomTextField(
                            controller: _shortNameController,
                            onChanged: (shortName) =>
                                BlocProvider.of<HabitCreationFormBloc>(context)
                                    .add(HabitCreationFormShortNameChangedEvent(
                                        shortName)),
                            label: AppLocalizations.of(context)!.shortName,
                            errorText: displayShortNameErrorMessage,
                          ),

                          const SizedBox(height: 16.0),

                          // Long Name Input
                          CustomTextField(
                            controller: _longNameController,
                            onChanged: (longName) =>
                                BlocProvider.of<HabitCreationFormBloc>(context)
                                    .add(HabitCreationFormLongNameChangedEvent(
                                        longName)),
                            label: AppLocalizations.of(context)!.longName,
                            errorText: displayLongNameErrorMessage,
                          ),

                          const SizedBox(height: 16.0),

                          // Description Input
                          CustomTextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            onChanged: (description) => BlocProvider.of<
                                    HabitCreationFormBloc>(context)
                                .add(HabitCreationFormDescriptionChangedEvent(
                                    description)),
                            label: AppLocalizations.of(context)!.description,
                            errorText: displayDescriptionErrorMessage,
                          ),

                          const SizedBox(height: 16.0),

                          // Unit Selector
                          MultiUnitSelectDropdown(
                            initialSelectedValues: _selectedUnitIds.toList(),
                            options: habitState.units,
                            userLocale: userLocale,
                            errors: unitsErrorMap,
                            onUnitsChanged: (newUnits) {
                              _selectedUnitIds = newUnits;
                            },
                          ),

                          const SizedBox(height: 16.0),

                          // Icon Selector with error display
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomElevatedButtonFormField(
                                    onPressed: _pickIcon,
                                    iconData: Icons.select_all,
                                    label: AppLocalizations.of(context)!.icon,
                                    errorText: displayIconErrorMessage,
                                  ),
                                  const SizedBox(width: 16.0),
                                  if (_icon != null) Icon(_icon, size: 36),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16.0),

                          // Create Habit Button
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => _createHabit(userLocale),
                                child: Text(
                                    AppLocalizations.of(context)!.createHabit),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.addNewHabit),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
