import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_merge/habit_merge_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_merge/habit_merge_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_review/habit_review_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_review/habit_review_events.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class ReviewHabitScreen extends StatefulWidget {
  final String habitId;

  const ReviewHabitScreen({required this.habitId});

  @override
  ReviewHabitScreenState createState() => ReviewHabitScreenState();
}

class ReviewHabitScreenState extends State<ReviewHabitScreen> {
  Map<String, String> _shortNameControllerForCurrentHabit = {};
  Map<String, String> _longNameControllerForCurrentHabit = {};
  Map<String, String> _descriptionControllerForCurrentHabit = {};
  Map<String, String> _shortNameControllerForHabitToMergeWith = {};
  Map<String, String> _longNameControllerForHabitToMergeWith = {};
  Map<String, String> _descriptionControllerForHabitToMergeWith = {};

  String? _selectedCategoryIdForCurrentHabit;
  String? _iconForCurrentHabit;
  String? _selectedCategoryIdForHabitToMergeWith;
  String? _iconForHabitToMergeWith;
  String? _selectedHabitToMergeOnId;
  HashSet<String> _selectedUnitIdsForCurrentHabit = HashSet();
  HashSet<String> _selectedUnitIdsForHabitToMergeWith = HashSet();

  void _showEmojiPicker(
      BuildContext context, String userLocale, bool forCurrentHabit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CustomEmojiSelector(
        userLocale: userLocale,
        onEmojiSelected: (category, emoji) {
          if (mounted) {
            if (forCurrentHabit) {
              BlocProvider.of<HabitReviewFormBloc>(context).add(
                HabitReviewFormIconChangedEvent(emoji.emoji),
              );
            } else {
              BlocProvider.of<HabitMergeFormBloc>(context).add(
                HabitMergeFormIconChangedEvent(emoji.emoji),
              );
            }
          }

          if (forCurrentHabit) {
            setState(() {
              _iconForCurrentHabit = emoji.emoji;
            });
          } else {
            setState(() {
              _iconForHabitToMergeWith = emoji.emoji;
            });
          }

          Navigator.pop(context);
        },
      ),
    );
  }

  void _saveHabit() {
    final habitFormBloc = context.read<HabitReviewFormBloc>();

    // Dispatch validation events for all fields
    habitFormBloc.add(HabitReviewFormCategoryChangedEvent(
        _selectedCategoryIdForCurrentHabit ?? ""));
    habitFormBloc.add(HabitReviewFormShortNameChangedEvent(
        _shortNameControllerForCurrentHabit));
    habitFormBloc.add(HabitReviewFormLongNameChangedEvent(
        _longNameControllerForCurrentHabit));
    habitFormBloc.add(HabitReviewFormDescriptionChangedEvent(
        _descriptionControllerForCurrentHabit));
    habitFormBloc.add(HabitReviewFormIconChangedEvent(
        _iconForCurrentHabit != null ? _iconForCurrentHabit! : ""));

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (habitFormBloc.state.isValid) {
          final newHabitEvent = UpdateHabitEvent(
            habitId: widget.habitId,
            shortName: _shortNameControllerForCurrentHabit,
            longName: _longNameControllerForCurrentHabit,
            description: _descriptionControllerForCurrentHabit,
            categoryId: _selectedCategoryIdForCurrentHabit ?? "",
            icon: _iconForCurrentHabit ?? "",
            unitIds: _selectedUnitIdsForCurrentHabit,
          );

          if (mounted) {
            context.read<HabitBloc>().add(newHabitEvent);
          }
        }
      },
    );
  }

  void _mergeHabit() {
    final habitFormBloc = context.read<HabitMergeFormBloc>();

    // Dispatch validation events for all fields
    habitFormBloc
        .add(HabitMergeFormChangedEvent(_selectedHabitToMergeOnId ?? ""));
    habitFormBloc.add(HabitMergeFormCategoryChangedEvent(
        _selectedCategoryIdForHabitToMergeWith ?? ""));
    habitFormBloc.add(HabitMergeFormShortNameChangedEvent(
        _shortNameControllerForHabitToMergeWith));
    habitFormBloc.add(HabitMergeFormLongNameChangedEvent(
        _longNameControllerForHabitToMergeWith));
    habitFormBloc.add(HabitMergeFormDescriptionChangedEvent(
        _descriptionControllerForHabitToMergeWith));
    habitFormBloc
        .add(HabitMergeFormIconChangedEvent(_iconForHabitToMergeWith ?? ""));

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (habitFormBloc.state.isValid) {
          final mergeHabitEvent = MergeHabitsEvent(
            habitToDeleteId: widget.habitId,
            habitToMergeOnId: _selectedHabitToMergeOnId ?? "",
            shortName: _shortNameControllerForHabitToMergeWith,
            longName: _longNameControllerForHabitToMergeWith,
            description: _descriptionControllerForHabitToMergeWith,
            categoryId: _selectedCategoryIdForHabitToMergeWith ?? "",
            icon: _iconForHabitToMergeWith ?? "",
            unitIds: _selectedUnitIdsForHabitToMergeWith,
          );

          if (mounted) {
            context.read<HabitBloc>().add(mergeHabitEvent);
          }
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final habitState = context.watch<HabitBloc>().state;

    if (habitState is HabitsLoaded) {
      final habit = habitState.habits[widget.habitId]!;

      setState(() {
        _shortNameControllerForCurrentHabit = habit.shortName;
        _longNameControllerForCurrentHabit = habit.longName;
        _descriptionControllerForCurrentHabit = habit.description;
        _selectedCategoryIdForCurrentHabit = habit.categoryId;
        _selectedUnitIdsForCurrentHabit = habit.unitIds;
        _iconForCurrentHabit = habit.icon;
      });
    }
  }

  void changeSelectedHabit(
      String? newHabitToMergeWithId, Map<String, Habit> habits) {
    if (newHabitToMergeWithId != null) {
      final habitToMergeWith = habits[newHabitToMergeWithId]!;

      setState(() {
        _shortNameControllerForHabitToMergeWith = habitToMergeWith.shortName;
        _longNameControllerForHabitToMergeWith = habitToMergeWith.longName;
        _descriptionControllerForHabitToMergeWith =
            habitToMergeWith.description;
        _selectedHabitToMergeOnId = newHabitToMergeWithId;
        _selectedCategoryIdForHabitToMergeWith = habitToMergeWith.categoryId;
        _selectedUnitIdsForHabitToMergeWith = habitToMergeWith.unitIds;
        _iconForHabitToMergeWith = habitToMergeWith.icon;
      });
    } else {
      setState(() {
        _shortNameControllerForHabitToMergeWith = {};
        _longNameControllerForHabitToMergeWith = {};
        _descriptionControllerForHabitToMergeWith = {};
        _selectedHabitToMergeOnId = null;
        _selectedCategoryIdForHabitToMergeWith = null;
        _selectedUnitIdsForHabitToMergeWith = HashSet();
        _iconForHabitToMergeWith = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final habitState = context.watch<HabitBloc>().state;

    return BlocListener<HabitBloc, HabitState>(
      listener: (context, state) {
        if (state is HabitsLoaded && state.message is SuccessMessage) {
          final message = state.message as SuccessMessage;

          if (message.messageKey == "habitUpdated") {
            final updatedHabit = state.newlyUpdatedHabit;

            if (updatedHabit != null) {
              context.goNamed('allHabits');
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

            final Habit currentHabit = habitState.habits[widget.habitId]!;
            final Habit? habitToMergeOn = _selectedHabitToMergeOnId != null
                ? habitState.habits[_selectedHabitToMergeOnId]
                : null;

            final displayHabitCategoryErrorForCurrentHabit = context.select(
              (HabitReviewFormBloc habitReviewFormBloc) =>
                  habitReviewFormBloc.state.habitCategory.displayError,
            );
            final displayHabitCategoryErrorMessageForCurrentHabit =
                displayHabitCategoryErrorForCurrentHabit != null
                    ? getTranslatedMessage(
                        context,
                        ErrorMessage(displayHabitCategoryErrorForCurrentHabit
                            .messageKey))
                    : null;

            final shortNameErrorMapForCurrentHabit = context.select(
              (HabitReviewFormBloc habitReviewFormBloc) => Map.fromEntries(
                habitReviewFormBloc.state.shortName.entries.map(
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

            final longNameErrorMapForCurrentHabit = context.select(
              (HabitReviewFormBloc habitReviewFormBloc) => Map.fromEntries(
                habitReviewFormBloc.state.longName.entries.map(
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

            final descriptionErrorMapForCurrentHabit = context.select(
              (HabitReviewFormBloc habitReviewFormBloc) => Map.fromEntries(
                habitReviewFormBloc.state.description.entries.map(
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

            final displayIconErrorForCurrentHabit = context.select(
              (HabitReviewFormBloc habitReviewFormBloc) =>
                  habitReviewFormBloc.state.icon.displayError,
            );
            final displayIconErrorMessageForCurrentHabit =
                displayIconErrorForCurrentHabit != null
                    ? getTranslatedMessage(
                        context,
                        ErrorMessage(
                            displayIconErrorForCurrentHabit.messageKey))
                    : null;

            final displayHabitCategoryErrorForHabitToMergeWith = context.select(
              (HabitMergeFormBloc habitMergeFormBloc) =>
                  habitMergeFormBloc.state.habitCategory.displayError,
            );
            final displayHabitCategoryErrorMessageForHabitToMergeWith =
                displayHabitCategoryErrorForHabitToMergeWith != null
                    ? getTranslatedMessage(
                        context,
                        ErrorMessage(
                            displayHabitCategoryErrorForHabitToMergeWith
                                .messageKey))
                    : null;

            final shortNameErrorMapForHabitToMergeWith = context.select(
              (HabitMergeFormBloc habitMergeFormBloc) => Map.fromEntries(
                habitMergeFormBloc.state.shortName.entries.map(
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

            final longNameErrorMapForHabitToMergeWith = context.select(
              (HabitMergeFormBloc habitMergeFormBloc) => Map.fromEntries(
                habitMergeFormBloc.state.longName.entries.map(
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

            final descriptionErrorMapForHabitToMergeWith = context.select(
              (HabitMergeFormBloc habitMergeFormBloc) => Map.fromEntries(
                habitMergeFormBloc.state.description.entries.map(
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

            final displayIconErrorForHabitToMergeWith = context.select(
              (HabitMergeFormBloc habitMergeFormBloc) =>
                  habitMergeFormBloc.state.icon.displayError,
            );
            final displayIconErrorMessageForHabitToMergeWith =
                displayIconErrorForHabitToMergeWith != null
                    ? getTranslatedMessage(
                        context,
                        ErrorMessage(
                            displayIconErrorForHabitToMergeWith.messageKey))
                    : null;

            final unitsErrorMapForCurrentHabit = context.select(
              (HabitReviewFormBloc habitReviewFormBloc) =>
                  habitReviewFormBloc.state.unitIds.values
                      .map((validator) => validator.displayError != null
                          ? getTranslatedMessage(
                              context,
                              ErrorMessage(validator.displayError!.messageKey),
                            )
                          : '')
                      .where((error) => error.isNotEmpty)
                      .toList(),
            );

            final unitsErrorMapForHabitToMergeWith = context.select(
              (HabitMergeFormBloc habitMergeFormBloc) =>
                  habitMergeFormBloc.state.unitIds.values
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
                  AppLocalizations.of(context)!.reviewHabit,
                  style: context.typographies.headingSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Category Selector
                      CustomDropdownButtonFormField(
                        value: _selectedCategoryIdForCurrentHabit,
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
                          BlocProvider.of<HabitReviewFormBloc>(context).add(
                              HabitReviewFormCategoryChangedEvent(value ?? ""));
                          setState(() {
                            _selectedCategoryIdForCurrentHabit = value;
                          });
                        },
                        label: AppLocalizations.of(context)!.category,
                        errorText:
                            displayHabitCategoryErrorMessageForCurrentHabit,
                      ),

                      const SizedBox(height: 16.0),

                      // Short Name Input
                      MultiLanguageInputField(
                        initialTranslations: currentHabit.shortName,
                        onTranslationsChanged:
                            (Map<String, String> translations) {
                          _shortNameControllerForCurrentHabit = translations;
                          BlocProvider.of<HabitReviewFormBloc>(context).add(
                            HabitReviewFormShortNameChangedEvent(translations),
                          );
                        },
                        label: AppLocalizations.of(context)!.shortName,
                        errors: shortNameErrorMapForCurrentHabit,
                      ),

                      // Long Name Input
                      MultiLanguageInputField(
                        initialTranslations: currentHabit.longName,
                        onTranslationsChanged:
                            (Map<String, String> translations) {
                          _longNameControllerForCurrentHabit = translations;
                          BlocProvider.of<HabitReviewFormBloc>(context).add(
                            HabitReviewFormLongNameChangedEvent(translations),
                          );
                        },
                        label: AppLocalizations.of(context)!.longName,
                        errors: longNameErrorMapForCurrentHabit,
                      ),

                      // Description Input
                      MultiLanguageInputField(
                        initialTranslations: currentHabit.description,
                        onTranslationsChanged:
                            (Map<String, String> translations) {
                          _descriptionControllerForCurrentHabit = translations;
                          BlocProvider.of<HabitReviewFormBloc>(context).add(
                            HabitReviewFormDescriptionChangedEvent(
                                translations),
                          );
                        },
                        label: AppLocalizations.of(context)!.description,
                        errors: descriptionErrorMapForCurrentHabit,
                      ),

                      const SizedBox(height: 16.0),

                      // Unit Selector
                      MultiUnitSelectDropdown(
                        initialSelectedValues:
                            _selectedUnitIdsForCurrentHabit.toList(),
                        options: habitState.units,
                        userLocale: userLocale,
                        errors: unitsErrorMapForCurrentHabit,
                        onUnitsChanged: (newUnits) {
                          _selectedUnitIdsForCurrentHabit = newUnits;
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
                                onPressed: () => _showEmojiPicker(
                                  context,
                                  userLocale,
                                  true,
                                ),
                                iconData: Icons.emoji_emotions,
                                label: AppLocalizations.of(context)!.icon,
                                errorText:
                                    displayIconErrorMessageForCurrentHabit,
                              ),
                              const SizedBox(width: 16.0),
                              if (_iconForCurrentHabit != null)
                                Text(
                                  _iconForCurrentHabit!,
                                  style: TextStyle(fontSize: 24),
                                ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16.0),

                      // Save Habit Button
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => _saveHabit(),
                            child:
                                Text(AppLocalizations.of(context)!.saveHabit),
                          ),
                        ],
                      ),

                      // -----------------------
                      // For habit to merge with
                      // -----------------------
                      const SizedBox(height: 16.0),

                      Text(
                        "Or merge with an existing habit",
                        style: context.typographies.bodyLarge,
                      ),

                      const SizedBox(height: 16.0),

                      // Habit Selector
                      CustomDropdownButtonFormField(
                        value: _selectedHabitToMergeOnId,
                        items: habitState.habits.entries
                            .map(
                              (entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(
                                  getRightTranslationFromJson(
                                    entry.value.shortName,
                                    userLocale,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          BlocProvider.of<HabitMergeFormBloc>(context)
                              .add(HabitMergeFormChangedEvent(value ?? ""));
                          changeSelectedHabit(value, habitState.habits);
                        },
                        label: AppLocalizations.of(context)!.habit,
                      ),

                      const SizedBox(height: 16.0),

                      if (_selectedHabitToMergeOnId != null &&
                          habitToMergeOn != null) ...[
                        // Category Selector
                        CustomDropdownButtonFormField(
                          value: _selectedCategoryIdForHabitToMergeWith,
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
                            BlocProvider.of<HabitMergeFormBloc>(context).add(
                                HabitMergeFormCategoryChangedEvent(
                                    value ?? ""));
                            setState(() {
                              _selectedCategoryIdForHabitToMergeWith = value;
                            });
                          },
                          label: AppLocalizations.of(context)!.category,
                          errorText:
                              displayHabitCategoryErrorMessageForHabitToMergeWith,
                        ),

                        const SizedBox(height: 16.0),

                        // Short Name Input
                        MultiLanguageInputField(
                          initialTranslations: habitToMergeOn.shortName,
                          onTranslationsChanged:
                              (Map<String, String> translations) {
                            _shortNameControllerForHabitToMergeWith =
                                translations;
                            BlocProvider.of<HabitMergeFormBloc>(context).add(
                              HabitMergeFormShortNameChangedEvent(translations),
                            );
                          },
                          label: AppLocalizations.of(context)!.shortName,
                          errors: shortNameErrorMapForHabitToMergeWith,
                        ),

                        // Long Name Input
                        MultiLanguageInputField(
                          initialTranslations: habitToMergeOn.longName,
                          onTranslationsChanged:
                              (Map<String, String> translations) {
                            _longNameControllerForHabitToMergeWith =
                                translations;
                            BlocProvider.of<HabitMergeFormBloc>(context).add(
                              HabitMergeFormLongNameChangedEvent(translations),
                            );
                          },
                          label: AppLocalizations.of(context)!.longName,
                          errors: longNameErrorMapForHabitToMergeWith,
                        ),

                        // Description Input
                        MultiLanguageInputField(
                          initialTranslations: habitToMergeOn.description,
                          onTranslationsChanged:
                              (Map<String, String> translations) {
                            _descriptionControllerForHabitToMergeWith =
                                translations;
                            BlocProvider.of<HabitMergeFormBloc>(context).add(
                              HabitMergeFormDescriptionChangedEvent(
                                  translations),
                            );
                          },
                          label: AppLocalizations.of(context)!.description,
                          errors: descriptionErrorMapForHabitToMergeWith,
                        ),

                        const SizedBox(height: 16.0),

                        // Unit Selector
                        MultiUnitSelectDropdown(
                          initialSelectedValues:
                              _selectedUnitIdsForHabitToMergeWith.toList(),
                          options: habitState.units,
                          userLocale: userLocale,
                          errors: unitsErrorMapForHabitToMergeWith,
                          onUnitsChanged: (newUnits) {
                            _selectedUnitIdsForHabitToMergeWith = newUnits;
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
                                  onPressed: () => _showEmojiPicker(
                                    context,
                                    userLocale,
                                    false,
                                  ),
                                  iconData: Icons.emoji_emotions,
                                  label: AppLocalizations.of(context)!.icon,
                                  errorText:
                                      displayIconErrorMessageForHabitToMergeWith,
                                ),
                                const SizedBox(width: 16.0),
                                if (_iconForHabitToMergeWith != null)
                                  Text(
                                    _iconForHabitToMergeWith!,
                                    style: TextStyle(fontSize: 24),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16.0),

                        // Merge Habit Button
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => _mergeHabit(),
                              child: Text(
                                  AppLocalizations.of(context)!.mergeHabit),
                            ),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
              appBar: CustomAppBar(
                title: Text(
                  AppLocalizations.of(context)!.reviewHabit,
                  style: context.typographies.headingSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
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
