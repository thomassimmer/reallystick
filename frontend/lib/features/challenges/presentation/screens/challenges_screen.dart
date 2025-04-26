import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_scroll_view.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/widgets/challenge_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class ChallengesScreen extends StatefulWidget {
  final bool previewMode;

  const ChallengesScreen({
    required this.previewMode,
  });

  @override
  ChallengesScreenState createState() => ChallengesScreenState();
}

class ChallengesScreenState extends State<ChallengesScreen> {
  bool _isCreatedChallengesExpanded = true;
  bool _isOngoingChallengesExpanded = true;
  bool _isMarkedAsFinishedChallengesExpanded = true;

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
        final profileState = widget.previewMode
            ? getProfileAuthenticatedForPreview(context)
            : context.watch<ProfileBloc>().state;
        final challengeState = widget.previewMode
            ? getChallengeStateForPreview(context)
            : context.watch<ChallengeBloc>().state;

        if (profileState is ProfileAuthenticated &&
            challengeState is ChallengesLoaded) {
          final challenges = challengeState.challenges.values.toList();

          final createdChallenges = challenges
              .where((challenge) =>
                  challenge.creator == profileState.profile.id &&
                  !challenge.deleted)
              .toList();

          List<ChallengeParticipation> markedAsFinishedParticipations = [];
          List<ChallengeParticipation> ongoingParticipations = [];

          for (final challengeParticipation
              in challengeState.challengeParticipations) {
            if (challengeParticipation.finished) {
              markedAsFinishedParticipations.add(challengeParticipation);
            } else {
              ongoingParticipations.add(challengeParticipation);
            }
          }

          return Scaffold(
            appBar: CustomAppBar(
              title: Text(
                AppLocalizations.of(context)!.challenges,
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
                      Icons.add_outlined,
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
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: FullWidthScrollView(
                  slivers: [
                    if (createdChallenges.isNotEmpty ||
                        ongoingParticipations.isNotEmpty ||
                        markedAsFinishedParticipations.isNotEmpty) ...[
                      if (ongoingParticipations.isNotEmpty) ...[
                        SliverAppBar(
                          pinned: true,
                          backgroundColor: context.colors.background,
                          title: InkWell(
                            onTap: () {
                              setState(() {
                                _isOngoingChallengesExpanded =
                                    !_isOngoingChallengesExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .ongoingChallenges,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  _isOngoingChallengesExpanded
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
                            crossFadeState: _isOngoingChallengesExpanded
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: Column(
                              children: ongoingParticipations.map(
                                (challengeParticipation) {
                                  final challenge = challengeState.challenges[
                                      challengeParticipation.challengeId]!;

                                  var challengeDailyTrackings = challengeState
                                      .challengeDailyTrackings[challenge.id];

                                  if (challengeDailyTrackings == null) {
                                    BlocProvider.of<ChallengeBloc>(context).add(
                                      GetChallengeDailyTrackingsEvent(
                                        challengeId: challenge.id,
                                      ),
                                    );
                                    challengeDailyTrackings = [];
                                  }

                                  return ChallengeWidget(
                                    challenge: challenge,
                                    challengeParticipation:
                                        challengeParticipation,
                                    challengeDailyTrackings:
                                        challengeDailyTrackings,
                                    previewMode: widget.previewMode,
                                  );
                                },
                              ).toList(),
                            ),
                            secondChild: Container(),
                          ),
                        ),
                      ],
                      if (createdChallenges.isNotEmpty) ...[
                        SliverAppBar(
                          pinned: true,
                          backgroundColor: context.colors.background,
                          title: InkWell(
                            onTap: () {
                              setState(() {
                                _isCreatedChallengesExpanded =
                                    !_isCreatedChallengesExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .createdChallenges,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  _isCreatedChallengesExpanded
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
                            crossFadeState: _isCreatedChallengesExpanded
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: Column(
                              children: createdChallenges.map(
                                (challenge) {
                                  return ChallengeWidget(
                                    challenge: challenge,
                                    challengeParticipation: null,
                                    challengeDailyTrackings: [],
                                    previewMode: widget.previewMode,
                                  );
                                },
                              ).toList(),
                            ),
                            secondChild: Container(),
                          ),
                        ),
                      ],
                      if (markedAsFinishedParticipations.isNotEmpty) ...[
                        SliverAppBar(
                          pinned: true,
                          backgroundColor: context.colors.background,
                          title: InkWell(
                            onTap: () {
                              setState(() {
                                _isMarkedAsFinishedChallengesExpanded =
                                    !_isMarkedAsFinishedChallengesExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .markedAsFinishedChallenges,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  _isMarkedAsFinishedChallengesExpanded
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
                                _isMarkedAsFinishedChallengesExpanded
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                            firstChild: Column(
                              children: markedAsFinishedParticipations.map(
                                (challengeParticipation) {
                                  final challenge = challengeState.challenges[
                                      challengeParticipation.challengeId]!;

                                  var challengeDailyTrackings = challengeState
                                      .challengeDailyTrackings[challenge.id];

                                  if (challengeDailyTrackings == null) {
                                    BlocProvider.of<ChallengeBloc>(context).add(
                                      GetChallengeDailyTrackingsEvent(
                                        challengeId: challenge.id,
                                      ),
                                    );
                                    challengeDailyTrackings = [];
                                  }

                                  return ChallengeWidget(
                                    challenge: challenge,
                                    challengeParticipation:
                                        challengeParticipation,
                                    challengeDailyTrackings:
                                        challengeDailyTrackings,
                                    previewMode: widget.previewMode,
                                  );
                                },
                              ).toList(),
                            ),
                            secondChild: Container(),
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
