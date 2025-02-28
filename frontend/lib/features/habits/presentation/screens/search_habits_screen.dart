import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

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
      final filteredHabits = habits
          .where((habit) =>
              habit.shortName.values.any((name) =>
                  name.toLowerCase().contains(searchQuery.toLowerCase())) ||
              habit.longName.values.any((name) =>
                  name.toLowerCase().contains(searchQuery.toLowerCase())))
          .toList();

      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.addANewHabit),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
            Expanded(
              child: ListView.builder(
                itemCount: filteredHabits.isNotEmpty
                    ? filteredHabits.length +
                        1 // +1 for the "Create Habit" button
                    : 1, // Only show the message and button when no habits match
                itemBuilder: (context, index) {
                  if (filteredHabits.isNotEmpty &&
                      index < filteredHabits.length) {
                    // Render habit items
                    final habit = filteredHabits[index];
                    final category = habitCategories[habit.categoryId];

                    return ListTile(
                      title: Text(
                        getRightTranslationFromJson(
                          habit.longName,
                          userLocale,
                        ),
                      ),
                      subtitle: Text(
                        category != null
                            ? getRightTranslationFromJson(
                                category.name,
                                userLocale,
                              )
                            : AppLocalizations.of(context)!.unknown,
                      ),
                      onTap: () {
                        context.pushNamed(
                          'habitDetails',
                          pathParameters: {'habitId': habit.id},
                        );
                      },
                    );
                  } else {
                    // Render no results message and the "Create Habit" button
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      child: Column(
                        children: [
                          if (filteredHabits.isEmpty)
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
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
