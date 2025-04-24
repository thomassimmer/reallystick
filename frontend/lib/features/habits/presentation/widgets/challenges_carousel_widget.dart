import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_statistic.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class ChallengesCarouselWidget extends StatelessWidget {
  final Color habitColor;
  final String habitId;
  final bool previewMode;

  const ChallengesCarouselWidget({
    required this.habitColor,
    required this.habitId,
    required this.previewMode,
  });

  @override
  Widget build(BuildContext context) {
    final profileState = previewMode
        ? getProfileAuthenticatedForPreview(context)
        : context.watch<ProfileBloc>().state;
    final habitState = previewMode
        ? getHabitsLoadedForPreview(context)
        : context.watch<HabitBloc>().state;
    final challengeState = previewMode
        ? getChallengeStateForPreview(context)
        : context.watch<ChallengeBloc>().state;

    if (habitState is HabitsLoaded &&
        profileState is ProfileAuthenticated &&
        challengeState is ChallengesLoaded) {
      final userLocale = profileState.profile.locale;
      final habitStatistic = habitState.habitStatistics[habitId];

      final challenges = habitStatistic?.challenges
              .map((challengeId) => challengeState.challenges[challengeId])
              .whereType<Challenge>()
              .toList() ??
          [];

      final challengesStatistics = challenges
          .map((challenge) => challengeState.challengeStatistics[challenge.id])
          .whereType<ChallengeStatistic>()
          .toList();
      challengesStatistics
          .sort((a, b) => b.participantsCount.compareTo(a.participantsCount));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                size: 20,
                color: habitColor,
              ),
              SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.relatedChallenges,
                style: TextStyle(
                  fontSize: 20,
                  color: habitColor,
                ),
              ),
              Spacer(),
              Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: AppLocalizations.of(context)!.challengesInfoTooltip,
                child: Icon(
                  Icons.info_outline,
                  size: 25,
                  color: habitColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (challenges.isNotEmpty) ...[
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...challenges.asMap().map(
                      (index, challenge) {
                        final challengeStatistics = challengesStatistics[index];

                        return MapEntry(
                          index,
                          Container(
                            width: 350,
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  habitColor.withAlpha(100),
                                  habitColor.withBlue(100).withAlpha(100)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: habitColor.withValues(alpha: 0.3),
                                  blurRadius: 5,
                                ),
                              ],
                              border: Border.all(width: 1, color: habitColor),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                context.pushNamed(
                                  'challengeDetails',
                                  pathParameters: {
                                    'challengeId': challenge.id,
                                    'challengeParticipationId': 'null'
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(challenge.icon,
                                            style: TextStyle(fontSize: 25)),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            getRightTranslationFromJson(
                                              challenge.name,
                                              userLocale,
                                            ),
                                            style: TextStyle(
                                              color:
                                                  context.colors.textOnPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          challenge.startDate != null ? 5 : 20,
                                    ),
                                    if (challenge.startDate != null) ...[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Spacer(),
                                          SizedBox(
                                            width: 150,
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .startsOn(
                                                DateFormat.yMMMd(
                                                        userLocale.toString())
                                                    .format(
                                                        challenge.startDate!),
                                              ),
                                              style: TextStyle(
                                                color: context
                                                    .colors.textOnPrimary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.end,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.people,
                                          color: context.colors.textOnPrimary,
                                          size: 12,
                                        ),
                                        SizedBox(width: 10),
                                        SizedBox(
                                          width: 140,
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .joinedByXPeople(
                                                    challengeStatistics
                                                        .participantsCount),
                                            style: TextStyle(
                                              color:
                                                  context.colors.textOnPrimary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Spacer(),
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .createdBy(
                                              challengeStatistics
                                                  .creatorUsername,
                                            ),
                                            style: TextStyle(
                                              color:
                                                  context.colors.textOnPrimary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ).values,
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: habitColor.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context.pushNamed('createChallenge');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.addNewChallenge,
                              style: TextStyle(color: context.colors.text),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: habitColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  context.pushNamed('createChallenge');
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.noChallengesForHabitYet,
                      style: TextStyle(color: context.colors.text),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(habitColor),
        ),
      );
    }
  }
}
