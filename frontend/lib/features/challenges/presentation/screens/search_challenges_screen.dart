import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class SearchChallengesScreen extends StatefulWidget {
  @override
  SearchChallengesScreenState createState() => SearchChallengesScreenState();
}

class SearchChallengesScreenState extends State<SearchChallengesScreen> {
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
    final challengeState = context.watch<ChallengeBloc>().state;

    if (profileState is ProfileAuthenticated &&
        challengeState is ChallengesLoaded) {
      final userLocale = profileState.profile.locale;

      final List<Challenge> challenges =
          challengeState.challenges.values.toList();

      // Filter challenges based on the search query
      final filteredChallenges = challenges
          .where((challenge) => challenge.name.values.any(
              (name) => name.toLowerCase().contains(searchQuery.toLowerCase())))
          .toList();

      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.addANewChallenge),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.searchChallenges,
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
                itemCount: filteredChallenges.isNotEmpty
                    ? filteredChallenges.length +
                        1 // +1 for the "Create Challenge" button
                    : 1, // Only show the message and button when no challenges match
                itemBuilder: (context, index) {
                  if (filteredChallenges.isNotEmpty &&
                      index < filteredChallenges.length) {
                    // Render challenge items
                    final challenge = filteredChallenges[index];

                    return ListTile(
                      title: Text(
                        getRightTranslationFromJson(
                          challenge.name,
                          userLocale,
                        ),
                      ),
                      subtitle: Text(getRightTranslationFromJson(
                        challenge.description,
                        userLocale,
                      )),
                      onTap: () {
                        context.pushNamed(
                          'challengeDetails',
                          pathParameters: {'challengeId': challenge.id},
                        );
                      },
                    );
                  } else {
                    // Render no results message and the "Create Challenge" button
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      child: Column(
                        children: [
                          if (filteredChallenges.isEmpty)
                            Text(
                              AppLocalizations.of(context)!.noResultsFound,
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              context.goNamed('createChallenge');
                            },
                            child: Text(
                              AppLocalizations.of(context)!.createANewChallenge,
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
