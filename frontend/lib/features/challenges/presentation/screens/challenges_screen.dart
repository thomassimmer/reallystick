import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_scroll_view.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/widgets/challenge_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class ChallengesScreen extends StatefulWidget {
  @override
  ChallengesScreenState createState() => ChallengesScreenState();
}

class ChallengesScreenState extends State<ChallengesScreen> {
  void onRetry() {
    BlocProvider.of<ChallengeBloc>(context).add(ChallengeInitializeEvent());
  }

  Future<void> _pullRefresh() async {
    BlocProvider.of<ChallengeBloc>(context).add(ChallengeInitializeEvent());
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final profileState = context.watch<ProfileBloc>().state;
        final challengeState = context.watch<ChallengeBloc>().state;

        if (profileState is ProfileAuthenticated &&
            challengeState is ChallengesLoaded) {
          final challenges = challengeState.challenges.values.toList();

          final createdChallenges = challenges
              .where((challenge) =>
                  challenge.creator == profileState.profile.id &&
                  !challenge.deleted)
              .toList();

          final participatedChallenges = challenges
              .where((challenge) =>
                  challenge.creator != profileState.profile.id &&
                  challengeState.challengeParticipations
                      .where((cp) => cp.challengeId == challenge.id)
                      .isNotEmpty)
              .toList();

          return Scaffold(
            appBar: CustomAppBar(
              title: Text(
                AppLocalizations.of(context)!.myChallenges,
                style: context.typographies.heading,
              ),
              centerTitle: false,
              actions: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: InkWell(
                    onTap: () {
                      context.goNamed('challengeSearch');
                    },
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _pullRefresh,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4),
                child: FullWidthScrollView(
                  slivers: [
                    if (createdChallenges.isNotEmpty ||
                        participatedChallenges.isNotEmpty) ...[
                      if (createdChallenges.isNotEmpty) ...[
                        SliverAppBar(
                          title: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.createdChallenges,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final challenge = createdChallenges[index];

                              final challengeParticipation = challengeState
                                  .challengeParticipations
                                  .where((challengeParticipation) =>
                                      challengeParticipation.challengeId ==
                                      challenge.id)
                                  .firstOrNull;

                              var challengeDailyTrackings = challengeState
                                  .challengeDailyTrackings[challenge.id];

                              if (challengeDailyTrackings == null) {
                                BlocProvider.of<ChallengeBloc>(context).add(
                                  GetChallengeDailyTrackingsEvent(
                                      challengeId: challenge.id),
                                );
                                challengeDailyTrackings = [];
                              }

                              return ChallengeWidget(
                                challenge: challenge,
                                challengeParticipation: challengeParticipation,
                                challengeDailyTrackings:
                                    challengeDailyTrackings,
                              );
                            },
                            childCount: createdChallenges.length,
                          ),
                        ),
                      ],
                      if (participatedChallenges.isNotEmpty) ...[
                        SliverAppBar(
                          title: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .participatedChallenges,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final challenge = participatedChallenges[index];

                              final challengeParticipation = challengeState
                                  .challengeParticipations
                                  .where((challengeParticipation) =>
                                      challengeParticipation.challengeId ==
                                      challenge.id)
                                  .firstOrNull;

                              var challengeDailyTrackings = challengeState
                                  .challengeDailyTrackings[challenge.id];

                              if (challengeDailyTrackings == null) {
                                BlocProvider.of<ChallengeBloc>(context).add(
                                  GetChallengeDailyTrackingsEvent(
                                      challengeId: challenge.id),
                                );
                                challengeDailyTrackings = [];
                              }

                              return ChallengeWidget(
                                challenge: challenge,
                                challengeParticipation: challengeParticipation,
                                challengeDailyTrackings:
                                    challengeDailyTrackings,
                              );
                            },
                            childCount: participatedChallenges.length,
                          ),
                        ),
                      ],
                    ] else ...[
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.noChallengesYet,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.goNamed('challengeSearch');
                                },
                                icon: const Icon(Icons.add),
                                label: Text(
                                  AppLocalizations.of(context)!.addNewChallenge,
                                ),
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
        } else if (challengeState is ChallengesFailed) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.failedToLoadChallenges,
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
    );
  }
}
