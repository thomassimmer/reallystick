import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/helpers/challenge_date.dart';
import 'package:reallystick/features/challenges/presentation/widgets/daily_tracking_carousel_with_start_date_widget.dart';
import 'package:reallystick/features/challenges/presentation/widgets/daily_tracking_carousel_without_start_date_widget.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';

class ChallengeWidget extends StatelessWidget {
  final Challenge challenge;
  final ChallengeParticipation? challengeParticipation;
  final List<ChallengeDailyTracking> challengeDailyTrackings;

  const ChallengeWidget({
    super.key,
    required this.challenge,
    required this.challengeParticipation,
    required this.challengeDailyTrackings,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final profileState = context.watch<ProfileBloc>().state;
        final challengeState = context.watch<ChallengeBloc>().state;

        if (challengeState is ChallengesLoaded) {
          final userLocale = profileState.profile!.locale;

          final name = getRightTranslationFromJson(
            challenge.name,
            userLocale,
          );

          final challengeColor =
              AppColorExtension.fromString(challengeParticipation?.color ?? "")
                  .color;

          final bool isLargeScreen = checkIfLargeScreen(context);

          final bool finished = checkIfChallengeIsFinished(
            challengeDailyTrackings: challengeDailyTrackings,
            challengeStartDate: challenge.startDate,
            challengeParticipation: challengeParticipation,
          );

          return !challenge.deleted
              ? InkWell(
                  onTap: () {
                    context.goNamed(
                      'challengeDetails',
                      pathParameters: {
                        'challengeId': challenge.id,
                        'challengeParticipationId':
                            challengeParticipation?.id ?? "null",
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(10.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        if (finished)
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.green),
                                  right: BorderSide(color: Colors.green),
                                  bottom: BorderSide(color: Colors.green),
                                ),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withAlpha(50),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child:
                                  Text(AppLocalizations.of(context)!.finished),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            16.0,
                            finished ? 0.0 : 16.0,
                            16.0,
                            16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: Text(
                                              challenge.icon,
                                              style: TextStyle(
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: challengeColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (challengeParticipation != null) ...[
                                        SizedBox(height: 10),
                                        Text(
                                          "${AppLocalizations.of(context)!.challengeParticipationStartDate} ${DateFormat.yMMMd().format(challengeParticipation!.startDate)}",
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ],
                                  ),
                                  if (isLargeScreen &&
                                      challengeParticipation != null) ...[
                                    Spacer(),
                                    challenge.startDate != null
                                        ? DailyTrackingCarouselWithStartDateWidget(
                                            challengeParticipation:
                                                challengeParticipation,
                                            challengeId: challenge.id,
                                            challengeDailyTrackings:
                                                challengeDailyTrackings,
                                            challengeColor: challengeColor,
                                            canOpenDayBoxes: false,
                                            displayTitle: false,
                                          )
                                        : DailyTrackingCarouselWithoutStartDateWidget(
                                            challengeParticipation:
                                                challengeParticipation,
                                            challengeId: challenge.id,
                                            challengeDailyTrackings:
                                                challengeDailyTrackings,
                                            challengeColor: challengeColor,
                                            canOpenDayBoxes: false,
                                            displayTitle: false,
                                          ),
                                  ],
                                ],
                              ),
                              if (!isLargeScreen &&
                                  challengeParticipation != null) ...[
                                const SizedBox(height: 8),
                                challenge.startDate != null
                                    ? DailyTrackingCarouselWithStartDateWidget(
                                        challengeParticipation:
                                            challengeParticipation,
                                        challengeId: challenge.id,
                                        challengeDailyTrackings:
                                            challengeDailyTrackings,
                                        challengeColor: challengeColor,
                                        canOpenDayBoxes: false,
                                        displayTitle: false,
                                      )
                                    : DailyTrackingCarouselWithoutStartDateWidget(
                                        challengeParticipation:
                                            challengeParticipation,
                                        challengeId: challenge.id,
                                        challengeDailyTrackings:
                                            challengeDailyTrackings,
                                        challengeColor: challengeColor,
                                        canOpenDayBoxes: false,
                                        displayTitle: false,
                                      ),
                              ],
                            ],
                          ),
                        ),
                      ],
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
