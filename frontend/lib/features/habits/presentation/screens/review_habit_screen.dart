import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/constants/icons.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_dropdown_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/custom_elevated_button_form_field.dart';
import 'package:reallystick/core/presentation/widgets/multi_language_input_field.dart';
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
  IconData? _iconForCurrentHabit;
  String? _selectedCategoryIdForHabitToMergeWith;
  IconData? _iconForHabitToMergeWith;
  String? _selectedHabitToMergeOnId;

  _pickIcon(bool forCurrentHabit) async {
    IconPickerIcon? icon = await showIconPicker(
      context,
      configuration: SinglePickerConfiguration(
        iconPackModes: [IconPack.material],
      ),
    );

    if (mounted) {
      if (forCurrentHabit) {
        BlocProvider.of<HabitReviewFormBloc>(context).add(
          HabitReviewFormIconChangedEvent(
              icon != null ? icon.data.codePoint.toString() : ""),
        );
      } else {
        BlocProvider.of<HabitMergeFormBloc>(context).add(
          HabitMergeFormIconChangedEvent(
              icon != null ? icon.data.codePoint.toString() : ""),
        );
      }
    }

    final newIconData = icon?.data;

    if (forCurrentHabit) {
      setState(() {
        _iconForCurrentHabit = newIconData;
      });
    } else {
      setState(() {
        _iconForHabitToMergeWith = newIconData;
        ;
      });
    }
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
        _iconForCurrentHabit != null
            ? _iconForCurrentHabit!.codePoint.toString()
            : ""));

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
            icon: _iconForCurrentHabit?.codePoint ?? 0,
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
    habitFormBloc.add(HabitMergeFormIconChangedEvent(
        _iconForHabitToMergeWith != null
            ? _iconForHabitToMergeWith!.codePoint.toString()
            : ""));

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
            icon: _iconForHabitToMergeWith?.codePoint ?? 0,
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
        _iconForCurrentHabit =
            getIconData(iconDataString: habit.icon.substring(10));
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
        _iconForHabitToMergeWith =
            getIconData(iconDataString: habitToMergeWith.icon.substring(10));
      });
    } else {
      setState(() {
        _shortNameControllerForHabitToMergeWith = {};
        _longNameControllerForHabitToMergeWith = {};
        _descriptionControllerForHabitToMergeWith = {};
        _selectedHabitToMergeOnId = null;
        _selectedCategoryIdForHabitToMergeWith = null;
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

            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.reviewHabit),
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

                      // Icon Selector with error display
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomElevatedButtonFormField(
                                onPressed: () => _pickIcon(true),
                                iconData: Icons.select_all,
                                label: AppLocalizations.of(context)!.icon,
                                errorText:
                                    displayIconErrorMessageForCurrentHabit,
                              ),
                              const SizedBox(width: 16.0),
                              if (_iconForCurrentHabit != null)
                                Icon(_iconForCurrentHabit, size: 36),
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

                        // Icon Selector with error display
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomElevatedButtonFormField(
                                  onPressed: () => _pickIcon(true),
                                  iconData: Icons.select_all,
                                  label: AppLocalizations.of(context)!.icon,
                                  errorText:
                                      displayIconErrorMessageForHabitToMergeWith,
                                ),
                                const SizedBox(width: 16.0),
                                if (_iconForHabitToMergeWith != null)
                                  Icon(_iconForHabitToMergeWith, size: 36),
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
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.reviewHabit),
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
