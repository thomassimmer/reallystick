import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/screens/add_daily_tracking_modal.dart';
import 'package:reallystick/features/habits/presentation/screens/questionnaire_modal.dart';
import 'package:reallystick/features/habits/presentation/widgets/add_activity_button.dart';
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

  void _showAddDailyTrackingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Wrap(
            children: [AddDailyTrackingModal()],
          ),
        );
      },
    );
  }

  void onRetry() {
    BlocProvider.of<HabitBloc>(context).add(HabitInitializeEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final profileState = context.watch<ProfileBloc>().state;

    if (profileState is ProfileAuthenticated &&
        !profileState.profile.hasSeenQuestions &&
        !_isModalShown) {
      // Delay modal presentation to avoid lifecycle conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showQuestionnaireBottomSheet(profileState);
        }
      });
    }
  }

  Future<void> _pullRefresh() async {
    BlocProvider.of<HabitBloc>(context).add(HabitInitializeEvent());
    await Future.delayed(Duration(seconds: 2));
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

            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        AppLocalizations.of(context)!.myHabits,
                        style: context.typographies.heading,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: InkWell(
                      onTap: () {
                        context.goNamed('habitSearch');
                      },
                      child: Icon(
                        Icons.add_circle_outline,
                        size: 30,
                      ),
                    ),
                  )
                ],
              ),
              body: RefreshIndicator(
                onRefresh: _pullRefresh,
                child: ListView(
                  children: [
                    if (categories.isNotEmpty) ...[
                      ListView.builder(
                        shrinkWrap: true, // Prevent it from taking full height
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final habitCategory = categories[index];

                          final habitParticipations = habitState
                              .habitParticipations
                              .where((habitParticipation) =>
                                  habitState
                                          .habits[habitParticipation.habitId] !=
                                      null &&
                                  habitState.habits[habitParticipation.habitId]!
                                          .categoryId ==
                                      habitCategory.id)
                              .toList();

                          final habitDailyTrackings = habitState
                              .habitDailyTrackings
                              .where((habitDailyTracking) =>
                                  habitState
                                          .habits[habitDailyTracking.habitId] !=
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
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.noHabitsYet,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.goNamed('habitSearch');
                                  },
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    AppLocalizations.of(context)!.addANewHabit,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              floatingActionButton: categories.isNotEmpty
                  ? AddActivityButton(action: _showAddDailyTrackingBottomSheet)
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            );
          } else if (habitState is HabitsFailed) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.failedToLoadHabits,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(AppLocalizations.of(context)!.retry),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
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
        // Find the habit participation associated with the tracking
        final habitParticipation = state.habitParticipations
            .where((hp) => hp.habitId == tracking.habitId)
            .toList()
            .firstOrNull;

        if (habitParticipation != null) {
          final categoryId = habit.categoryId;
          final currentLatest = categoryToLatestDate[categoryId];

          // Update the latest date for the category if this tracking is newer
          if (currentLatest == null ||
              tracking.datetime.isAfter(currentLatest)) {
            categoryToLatestDate[categoryId] = tracking.datetime;
          }
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

    // Step 4: Add categories without daily tracking data
    for (final participation in state.habitParticipations) {
      // Find the habit associated with the tracking
      final habit = state.habits[participation.habitId];

      if (habit != null) {
        // Find the habit associated with the tracking
        final habitCategory = state.habitCategories[habit.categoryId];

        if (habitCategory != null &&
            !sortedCategories.contains(habitCategory)) {
          sortedCategories.add(habitCategory);
        }
      }
    }

    return [...sortedCategories];
  }
}
