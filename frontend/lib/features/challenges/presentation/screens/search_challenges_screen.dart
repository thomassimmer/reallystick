import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_list_view_builder.dart';
import 'package:reallystick/core/ui/extensions.dart';
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

      final lowerQuery = searchQuery.toLowerCase();

      // Filter + sort by name
      final filteredChallenges = challenges.where((challenge) {
        final nameMatch = challenge.name.values
            .any((name) => name.toLowerCase().contains(lowerQuery));
        final descMatch = challenge.description.values
            .any((desc) => desc.toLowerCase().contains(lowerQuery));
        return nameMatch || descMatch;
      }).toList()
        ..sort((a, b) {
          final aName = getRightTranslationFromJson(a.name, userLocale);
          final bName = getRightTranslationFromJson(b.name, userLocale);
          return aName.toLowerCase().compareTo(bName.toLowerCase());
        });

      return Scaffold(
        appBar: CustomAppBar(
          title: Text(
            AppLocalizations.of(context)!.addNewChallenge,
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
                  context.pushNamed('createChallenge');
                },
                child: Icon(
                  Icons.add_outlined,
                  size: 25,
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
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.searchChallenges,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FullWidthListViewBuilder(
                itemCount: filteredChallenges.isNotEmpty
                    ? filteredChallenges.length
                    : 1,
                itemBuilder: (context, index) {
                  if (filteredChallenges.isNotEmpty) {
                    final challenge = filteredChallenges[index];
                    final isLast = index == filteredChallenges.length - 1;

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 5),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(challenge.icon,
                                  style: TextStyle(fontSize: 15)),
                            ],
                          ),
                          title: Text(
                            getRightTranslationFromJson(
                              challenge.name,
                              userLocale,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            getRightTranslationFromJson(
                              challenge.description,
                              userLocale,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          onTap: () {
                            context.pushNamed(
                              'challengeDetails',
                              pathParameters: {
                                'challengeId': challenge.id,
                                'challengeParticipationId': 'null',
                              },
                            );
                          },
                        ),
                        if (!isLast) const Divider(height: 1, thickness: 0.5),
                      ],
                    );
                  } else {
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
