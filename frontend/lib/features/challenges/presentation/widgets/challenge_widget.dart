import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/constants/icons.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/widgets/daily_tracking_carousel_widget.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';

class ChallengeWidget extends StatelessWidget {
  final Challenge challenge;
  final ChallengeParticipation? challengeParticipation;
  final List<ChallengeDailyTracking> challengeDailyTrackings;

  const ChallengeWidget({
    Key? key,
    required this.challenge,
    required this.challengeParticipation,
    required this.challengeDailyTrackings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final profileState = context.watch<ProfileBloc>().state;
        final challengeState = context.read<ChallengeBloc>().state;

        if (challengeState is ChallengesLoaded) {
          final userLocale = profileState.profile!.locale;

          final name = getRightTranslationFromJson(
            challenge.name,
            userLocale,
          );

          final challengeColor =
              AppColorExtension.fromString(challengeParticipation?.color ?? "")
                  .color;

          return !challenge.deleted
              ? InkWell(
                  onTap: () {
                    context.goNamed(
                      'challengeDetails',
                      pathParameters: {'challengeId': challenge.id},
                    );
                  },
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: getIconWidget(
                                  iconString: challenge.icon,
                                  size: 30,
                                  color: challengeColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: challengeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DailyTrackingCarouselWidget(
                            challengeId: challenge.id,
                            challengeDailyTrackings: challengeDailyTrackings,
                            challengeColor: challengeColor,
                            canOpenDayBoxes: false,
                            displayTitle: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Card(
                  elevation: 2,
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(
                                Icons.error,
                                size: 30,
                                color: challengeColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .challengeWasDeletedByCreator,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: challengeColor,
                                ),
                              ),
                            ),
                          ],
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
