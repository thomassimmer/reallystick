import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/screens/questionnaire_modal.dart';
import 'package:reallystick/features/habits/presentation/widgets/habit_category_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class HabitsScreen extends StatefulWidget {
  @override
  HabitsScreenState createState() => HabitsScreenState();
}

class HabitsScreenState extends State<HabitsScreen> {
  bool _isModalShown = false;

  void _showQuestionnaireBottomSheet(ProfileAuthenticated state) {
    setState(() {
      _isModalShown = true;
    });

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 1.0,
          minChildSize: 1.0,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return QuestionnaireModal(
              scrollController: scrollController,
              profile: state.profile,
            );
          },
        );
      },
    ).then((_) {
      if (mounted) {
        final newProfile = state.profile;
        newProfile.hasSeenQuestions = true;
        BlocProvider.of<ProfileBloc>(context).add(ProfileUpdateEvent(
          newProfile: newProfile,
          displayNotification: false,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileAuthenticated &&
            !state.profile.hasSeenQuestions &&
            !_isModalShown) {
          _showQuestionnaireBottomSheet(state);
        }
      },
      child: Builder(
        builder: (context) {
          final profileState = context.watch<ProfileBloc>().state;
          final habitState = context.watch<HabitBloc>().state;

          if (profileState is ProfileAuthenticated &&
              habitState is HabitsLoaded) {
            final categories = getCategoriesOrderedByLatestTracking(habitState);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.myHabits,
                          style: context.typographies.heading,
                        ),
                        InkWell(
                          onTap: () {
                            context.goNamed('habitSearch');
                          },
                          child: Icon(
                            Icons.add_circle_outline,
                            size: 30,
                          ),
                        )
                      ],
                    )),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final habitCategory = categories[index];

                      final habitParticipations = habitState.habitParticipations
                          .where((habitParticipation) =>
                              habitState.habits[habitParticipation.habitId] !=
                                  null &&
                              habitState.habits[habitParticipation.habitId]!
                                      .categoryId ==
                                  habitCategory.id)
                          .toList();

                      final habitDailyTrackings = habitState.habitDailyTrackings
                          .where((habitDailyTracking) =>
                              habitState.habits[habitDailyTracking.habitId] !=
                                  null &&
                              habitState.habits[habitDailyTracking.habitId]!
                                      .categoryId ==
                                  habitCategory.id)
                          .toList();

                      return HabitCategoryWidget(
                          habits: habitState.habits,
                          category: habitCategory,
                          habitParticipations: habitParticipations,
                          habitDailyTrackings: habitDailyTrackings);
                    },
                  ),
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  List<HabitCategory> getCategoriesOrderedByLatestTracking(HabitsLoaded state) {
    // Step 1: Map each category to the latest tracking date
    final categoryToLatestDate = <String, DateTime>{};

    for (final tracking in state.habitDailyTrackings) {
      // Find the habit associated with the tracking
      final habit = state.habits[tracking.habitId];
      if (habit != null) {
        final categoryId = habit.categoryId;
        final currentLatest = categoryToLatestDate[categoryId];

        // Update the latest date for the category if this tracking is newer
        if (currentLatest == null || tracking.day.isAfter(currentLatest)) {
          categoryToLatestDate[categoryId] = tracking.day;
        }
      }
    }

    // Step 2: Sort the categories by the latest tracking date
    final sortedCategoryIds = categoryToLatestDate.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Descending order

    // Step 3: Get sorted HabitCategory objects
    final sortedCategories = sortedCategoryIds.map((entry) {
      return state.habitCategories[entry.key]!;
    }).toList();

    return [...sortedCategories];
  }
}
