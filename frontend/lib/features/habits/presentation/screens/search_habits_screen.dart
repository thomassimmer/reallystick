import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_list_view_builder.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class SearchHabitsScreen extends StatefulWidget {
  @override
  SearchHabitsScreenState createState() => SearchHabitsScreenState();
}

class SearchHabitsScreenState extends State<SearchHabitsScreen> {
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final habitState = context.watch<HabitBloc>().state;

    if (profileState is ProfileAuthenticated && habitState is HabitsLoaded) {
      final userLocale = profileState.profile.locale;

      final List<Habit> habits = habitState.habits.values.toList();
      final Map<String, HabitCategory> habitCategories =
          habitState.habitCategories;

      // Filter habits based on the search query
      final lowerQuery = searchQuery.toLowerCase();

      final filteredHabits = habits.where((habit) {
        final nameMatches = habit.name.values.any(
          (name) => name.toLowerCase().contains(lowerQuery),
        );

        final descriptionMatches = habit.description.values.any(
          (desc) => desc.toLowerCase().contains(lowerQuery),
        );

        final categoryName = habitCategories[habit.categoryId]?.name.values;
        final categoryMatches = categoryName?.any(
              (catName) => catName.toLowerCase().contains(lowerQuery),
            ) ??
            false;

        return nameMatches || descriptionMatches || categoryMatches;
      }).toList();

      final Map<String, List<Habit>> groupedHabits = {};
      for (final habit in filteredHabits) {
        groupedHabits.putIfAbsent(habit.categoryId, () => []).add(habit);
      }

      final List<_GroupedHabitItem> habitListWithHeaders = [];

      final sortedCategoryIds = groupedHabits.keys.toList()
        ..sort((a, b) {
          final aName = habitCategories[a]?.name.values.first ?? '';
          final bName = habitCategories[b]?.name.values.first ?? '';
          return aName.compareTo(bName);
        });

      for (final categoryId in sortedCategoryIds) {
        final category = habitCategories[categoryId];
        if (category == null) continue;

        habitListWithHeaders.add(
          _GroupedHabitItem.categoryHeader(
            getRightTranslationFromJson(category.name, userLocale),
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
          habitListWithHeaders.add(_GroupedHabitItem.habit(habit));
        }
      }

      return Scaffold(
        appBar: CustomAppBar(
          title: Text(
            AppLocalizations.of(context)!.addNewHabit,
            style: context.typographies.headingSmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  context.pushNamed('createHabit');
                },
                child: Icon(
                  Icons.add_outlined,
                  size: 25,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 700), // Limit max width
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.searchHabits,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FullWidthListViewBuilder(
                  itemCount: habitListWithHeaders.isNotEmpty
                      ? habitListWithHeaders.length
                      : 1,
                  itemBuilder: (context, index) {
                    if (habitListWithHeaders.isNotEmpty) {
                      final item = habitListWithHeaders[index];

                      if (item.isCategoryHeader) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                          ),
                          child: Text(
                            item.categoryName!,
                          ),
                        );
                      } else {
                        final habit = item.habit!;
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 5),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(habit.icon,
                                      style: TextStyle(fontSize: 15)),
                                ],
                              ),
                              title: Text(
                                getRightTranslationFromJson(
                                    habit.name, userLocale),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                getRightTranslationFromJson(
                                    habit.description, userLocale),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              onTap: () {
                                context.pushNamed(
                                  'habitDetails',
                                  pathParameters: {'habitId': habit.id},
                                );
                              },
                            ),
                            if (index < habitListWithHeaders.length - 1 &&
                                !habitListWithHeaders[index + 1]
                                    .isCategoryHeader)
                              const Divider(height: 1, thickness: 0.5),
                          ],
                        );
                      }
                    } else {
                      // No results case (same as before)
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 32.0),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.noResultsFound,
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () {
                                context.pushNamed('createHabit');
                              },
                              child: Text(
                                AppLocalizations.of(context)!.createANewHabit,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class _GroupedHabitItem {
  final String? categoryName;
  final Habit? habit;

  _GroupedHabitItem.categoryHeader(this.categoryName) : habit = null;
  _GroupedHabitItem.habit(this.habit) : categoryName = null;

  bool get isCategoryHeader => categoryName != null;
}
