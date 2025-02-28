import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/constants/icons.dart';
import 'package:reallystick/core/ui/extensions.dart';
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

  const ChallengesCarouselWidget({
    required this.habitColor,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context) {
    final habitState = context.watch<HabitBloc>().state;
    final challengeState = context.watch<ChallengeBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;

    if (habitState is HabitsLoaded &&
        profileState is ProfileAuthenticated &&
        challengeState is ChallengesLoaded) {
      final userLocale = profileState.profile.locale;
      final habitStatistic = habitState.habitStatistics[habitId]!;
      final challenges = habitStatistic.challenges
          .map((challengeId) => challengeState.challenges[challengeId])
          .where((c) => c != null)
          .toList();
      final challengesStatistics = challenges
          .map(
              (challenge) => challengeState.challengeStatistics[challenge!.id]!)
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
                size: 30,
                color: habitColor,
              ),
              SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.relatedChallenges,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
                  color: habitColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (challenges.isNotEmpty) ...[
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  final challenge = challenges[index]!;
                  final challengeStatistics = challengesStatistics[index];

                  return Container(
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
                          color: habitColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        context.pushNamed(
                          'challengeDetails',
                          pathParameters: {'challengeId': challenge.id},
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  getIconData(
                                      iconDataString:
                                          challenge.icon.substring(10)),
                                  color: context.colors.textOnPrimary,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  getRightTranslationFromJson(
                                    challenge.name,
                                    userLocale,
                                  ),
                                  style: TextStyle(
                                    color: context.colors.textOnPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  color: context.colors.textOnPrimary,
                                  size: 12,
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .joinedByXPeople(challengeStatistics
                                            .participantsCount),
                                    style: TextStyle(
                                      color: context.colors.textOnPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Spacer(),
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    AppLocalizations.of(context)!.createdBy(
                                        challengeStatistics.creatorUsername),
                                    style: TextStyle(
                                      color: context.colors.textOnPrimary,
                                      fontSize: 12,
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
                  );
                },
              ),
            ),
          ] else ...[
            Row(
              children: [
                Container(
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
                        color: habitColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.pushNamed('createChallenge');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.noChallengesForHabitYet,
                          style: TextStyle(color: context.colors.textOnPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]
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
