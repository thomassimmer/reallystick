import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_scroll_view.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/screens/add_daily_tracking_modal.dart';
import 'package:reallystick/features/habits/presentation/screens/questionnaire_modal.dart';
import 'package:reallystick/features/habits/presentation/widgets/add_activity_button.dart';
import 'package:reallystick/features/habits/presentation/widgets/habit_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class HabitsScreen extends StatefulWidget {
  final bool previewMode;

  const HabitsScreen({
    required this.previewMode,
  });

  @override
  HabitsScreenState createState() => HabitsScreenState();
}

class HabitsScreenState extends State<HabitsScreen> {
  bool _isModalShown = false;
  Map<String, bool> _categoriesExpansion = {};

  void _showQuestionnaireBottomSheet(ProfileAuthenticated state) {
    setState(() {
      _isModalShown = true;
    });

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
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
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: SingleChildScrollView(
            child: Wrap(
              children: [AddDailyTrackingModal()],
            ),
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

    final profileState = widget.previewMode
        ? getProfileAuthenticatedForPreview(context)
        : context.watch<ProfileBloc>().state;

    if (profileState is ProfileAuthenticated &&
        !profileState.profile.hasSeenQuestions &&
        !_isModalShown) {
      // Delay modal presentation to avoid lifecycle conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showQuestionnaireBottomSheet(profileState);
      });
    }

    final habitState = widget.previewMode
        ? getHabitsLoadedForPreview(context)
        : context.watch<HabitBloc>().state;

    if (habitState is HabitsLoaded) {
      Map<String, bool> newCategoriesExpansion = {};

      for (final categoryId in habitState.habitCategories.keys) {
        newCategoriesExpansion[categoryId] = true;
      }

      setState(() {
        _categoriesExpansion = newCategoriesExpansion;
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
          final profileState = widget.previewMode
              ? getProfileAuthenticatedForPreview(context)
              : context.watch<ProfileBloc>().state;
          final habitState = widget.previewMode
              ? getHabitsLoadedForPreview(context)
              : context.watch<HabitBloc>().state;

          if (profileState is ProfileAuthenticated &&
              habitState is HabitsLoaded) {
            final categories = getCategoriesOrderedByLatestTracking(habitState);

            return Scaffold(
              appBar: CustomAppBar(
                title: Text(
                  AppLocalizations.of(context)!.habits,
                  style: context.typographies.heading,
                ),
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4,
                    ),
                    child: InkWell(
                      onTap: () {
                        context.goNamed('habitSearch');
                      },
                      child: Icon(
                        Icons.add_outlined,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: categories.isNotEmpty
                  ? AddActivityButton(
                      action: _showAddDailyTrackingBottomSheet,
                      label: null // AppLocalizations.of(context)!.addActivity,
                      )
                  : null,
              body: RefreshIndicator(
                onRefresh: _pullRefresh,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: FullWidthScrollView(
                    slivers: [
                      if (categories.isNotEmpty) ...[
                        ...categories.expand((habitCategory) {
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

                          final categoryName = getRightTranslationFromJson(
                            habitCategory.name,
                            profileState.profile.locale,
                          );

                          final sortedHabitParticipations =
                              getParticipationsOrderedByLatestTracking(
                            habitParticipations,
                            habitDailyTrackings,
                          );

                          return [
                            SliverAppBar(
                              pinned: true,
                              backgroundColor: context.colors.background,
                              title: InkWell(
                                borderRadius: BorderRadius.circular(10.0),
                                onTap: () {
                                  setState(() {
                                    _categoriesExpansion[habitCategory.id] =
                                        !_categoriesExpansion[
                                            habitCategory.id]!;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Text(
                                        habitCategory.icon,
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        categoryName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      _categoriesExpansion[habitCategory.id]!
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: AnimatedCrossFade(
                                duration: const Duration(milliseconds: 500),
                                crossFadeState:
                                    _categoriesExpansion[habitCategory.id]!
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                firstChild: Column(
                                  children: sortedHabitParticipations.map(
                                    (habitParticipation) {
                                      final habit = habitState
                                          .habits[habitParticipation.habitId]!;
                                      final habitDailyTrackingsForThisHabit =
                                          habitDailyTrackings
                                              .where((hdt) =>
                                                  hdt.habitId == habit.id)
                                              .toList();

                                      return HabitWidget(
                                        habit: habit,
                                        habitParticipation: habitParticipation,
                                        habitDailyTrackings:
                                            habitDailyTrackingsForThisHabit,
                                        previewMode: widget.previewMode,
                                        previewModeForChart: false,
                                      );
                                    },
                                  ).toList(),
                                ),
                                secondChild: SizedBox.shrink(),
                              ),
                            ),
                          ];
                        }),
                      ] else ...[
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
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
                                        AppLocalizations.of(context)!
                                            .addNewHabit,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
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

  List<HabitParticipation> getParticipationsOrderedByLatestTracking(
      List<HabitParticipation> habitParticipations,
      List<HabitDailyTracking> habitDailyTrackings) {
    // Step 1: Map each habitParticipation to the latest tracking date
    final participationToLatestDate = <String, DateTime>{};

    for (final tracking in habitDailyTrackings) {
      final participation = habitParticipations
          .where((hp) => hp.habitId == tracking.habitId)
          .toList()
          .firstOrNull;

      if (participation != null) {
        final currentLatest = participationToLatestDate[participation.id];
        if (currentLatest == null || tracking.datetime.isAfter(currentLatest)) {
          participationToLatestDate[participation.id] = tracking.datetime;
        }
      }
    }

    // Step 2: Sort the habit participations by the latest tracking date
    habitParticipations.sort((a, b) {
      final dateA = participationToLatestDate[a.id] ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = participationToLatestDate[b.id] ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA); // Descending order
    });

    return habitParticipations;
  }
}
