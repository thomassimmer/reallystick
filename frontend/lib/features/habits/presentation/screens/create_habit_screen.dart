import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/custom_dropdown_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/custom_elevated_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/emoji_selector.dart';
import 'package:reallystick/core/presentation/widgets/multi_language_input_field.dart';
import 'package:reallystick/core/presentation/widgets/multi_unit_select_dropdown.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_creation/habit_creation_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_creation/habit_creation_events.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class CreateHabitScreen extends StatefulWidget {
  @override
  CreateHabitScreenState createState() => CreateHabitScreenState();
}

class CreateHabitScreenState extends State<CreateHabitScreen> {
  Map<String, String> _nameController = {};
  Map<String, String> _descriptionController = {};
  String? _selectedCategoryId;
  String? _icon;
  HashSet<String> _selectedUnitIds = HashSet();

  void _showEmojiPicker(BuildContext context, String userLocale) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.background,
      builder: (context) => CustomEmojiSelector(
        userLocale: userLocale,
        onEmojiSelected: (category, emoji) {
          if (mounted) {
            BlocProvider.of<HabitCreationFormBloc>(context).add(
              HabitCreationFormIconChangedEvent(emoji.emoji),
            );
          }

          setState(() {
            _icon = emoji.emoji;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _createHabit(String locale) {
    final habitFormBloc = context.read<HabitCreationFormBloc>();

    // Dispatch validation events for all fields
    habitFormBloc
        .add(HabitCreationFormCategoryChangedEvent(_selectedCategoryId ?? ""));
    habitFormBloc.add(HabitCreationFormNameChangedEvent(_nameController));
    habitFormBloc
        .add(HabitCreationFormDescriptionChangedEvent(_descriptionController));
    habitFormBloc.add(HabitCreationFormIconChangedEvent(_icon ?? ""));

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (habitFormBloc.state.isValid) {
          final newHabitEvent = CreateHabitEvent(
            name: _nameController,
            description: _descriptionController,
            categoryId: _selectedCategoryId ?? "",
            icon: _icon ?? "",
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

            final nameErrorMap = context.select(
              (HabitCreationFormBloc habitCreationFormBloc) => Map.fromEntries(
                habitCreationFormBloc.state.name.entries.map(
                  (entry) => MapEntry(
                    entry.key,
                    entry.value.displayError != null
                        ? getTranslatedMessage(
                            context,
                            ErrorMessage(entry.value.displayError!.messageKey),
                          )
                        : null,
                  ),
                ),
              ),
            );

            final descriptionErrorMap = context.select(
              (HabitCreationFormBloc habitCreationFormBloc) => Map.fromEntries(
                habitCreationFormBloc.state.description.entries.map(
                  (entry) => MapEntry(
                    entry.key,
                    entry.value.displayError != null
                        ? getTranslatedMessage(
                            context,
                            ErrorMessage(entry.value.displayError!.messageKey),
                          )
                        : null,
                  ),
                ),
              ),
            );

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
              appBar: CustomAppBar(
                title: Text(
                  AppLocalizations.of(context)!.createANewHabit,
                  style: context.typographies.headingSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
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
                          Text(AppLocalizations.of(context)!.category),
                          const SizedBox(height: 16),
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
                            hint: AppLocalizations.of(context)!.category,
                            errorText: displayHabitCategoryErrorMessage,
                          ),

                          const SizedBox(height: 16.0),

                          // Name Input
                          MultiLanguageInputField(
                            initialTranslations: _nameController,
                            onTranslationsChanged: (translations) =>
                                BlocProvider.of<HabitCreationFormBloc>(context)
                                    .add(
                              HabitCreationFormNameChangedEvent(translations),
                            ),
                            label: AppLocalizations.of(context)!.habitName,
                            errors: nameErrorMap,
                            userLocale: userLocale,
                          ),

                          const SizedBox(height: 16.0),

                          // Description Input
                          MultiLanguageInputField(
                            initialTranslations: _descriptionController,
                            onTranslationsChanged: (translations) =>
                                BlocProvider.of<HabitCreationFormBloc>(context)
                                    .add(
                              HabitCreationFormDescriptionChangedEvent(
                                  translations),
                            ),
                            label: AppLocalizations.of(context)!.description,
                            errors: descriptionErrorMap,
                            userLocale: userLocale,
                          ),

                          const SizedBox(height: 16.0),

                          // Unit Selector
                          Text(AppLocalizations.of(context)!.unit),
                          const SizedBox(height: 16),
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
                          Text(AppLocalizations.of(context)!.icon),
                          const SizedBox(height: 16),
                          CustomElevatedButtonFormField(
                            onPressed: () =>
                                _showEmojiPicker(context, userLocale),
                            iconData: null,
                            label: _icon ??
                                AppLocalizations.of(context)!.chooseAnIcon,
                            errorText: displayIconErrorMessage,
                            labelSize: _icon != null ? 20 : null,
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
              appBar: CustomAppBar(
                title: Text(AppLocalizations.of(context)!.createANewHabit),
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
