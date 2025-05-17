import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/helpers/challenge_date.dart';
import 'package:reallystick/features/challenges/presentation/widgets/daily_tracking_carousel_with_start_date_widget.dart';
import 'package:reallystick/features/challenges/presentation/widgets/daily_tracking_carousel_without_start_date_widget.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class ChallengeWidget extends StatefulWidget {
  final Challenge challenge;
  final ChallengeParticipation? challengeParticipation;
  final List<ChallengeDailyTracking> challengeDailyTrackings;
  final bool previewMode;

  const ChallengeWidget({
    super.key,
    required this.challenge,
    required this.challengeParticipation,
    required this.challengeDailyTrackings,
    required this.previewMode,
  });
  @override
  ChallengeWidgetState createState() => ChallengeWidgetState();
}

class ChallengeWidgetState extends State<ChallengeWidget> {
  void _quitChallenge() {
    final deleteChallengeParticipationEvent = DeleteChallengeParticipationEvent(
      challengeParticipationId: widget.challengeParticipation!.id,
    );
    context.read<ChallengeBloc>().add(deleteChallengeParticipationEvent);
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

        if (challengeState is ChallengesLoaded) {
          final userLocale = profileState.profile!.locale;

          final name = getRightTranslationFromJson(
            widget.challenge.name,
            userLocale,
          );

          final challengeColor = AppColorExtension.fromString(
                  widget.challengeParticipation?.color ?? "")
              .color;

          final bool isLargeScreen = checkIfLargeScreen(context);

          final bool finished = checkIfChallengeIsFinished(
            challengeDailyTrackings: widget.challengeDailyTrackings,
            challengeStartDate: widget.challenge.startDate,
            challengeParticipation: widget.challengeParticipation,
          );

          return !widget.challenge.deleted
              ? InkWell(
                  onTap: () {
                    context.goNamed(
                      'challengeDetails',
                      pathParameters: {
                        'challengeId': widget.challenge.id,
                        'challengeParticipationId':
                            widget.challengeParticipation?.id ?? "null",
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16.0),
                                              child: Text(
                                                widget.challenge.icon,
                                                style: TextStyle(
                                                  fontSize: 25,
                                                ),
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
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (widget.challengeParticipation !=
                                            null) ...[
                                          SizedBox(height: 10),
                                          Text(
                                            "${AppLocalizations.of(context)!.challengeParticipationStartDate} ${DateFormat.yMMMd(userLocale).format(widget.challengeParticipation!.startDate)}",
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (isLargeScreen &&
                                      widget.challengeParticipation !=
                                          null) ...[
                                    widget.challenge.startDate != null
                                        ? DailyTrackingCarouselWithStartDateWidget(
                                            challengeParticipation:
                                                widget.challengeParticipation,
                                            challenge: widget.challenge,
                                            challengeDailyTrackings:
                                                widget.challengeDailyTrackings,
                                            challengeColor: challengeColor,
                                            canOpenDayBoxes: false,
                                            displayTitle: false,
                                            previewMode: widget.previewMode,
                                          )
                                        : DailyTrackingCarouselWithoutStartDateWidget(
                                            challengeParticipation:
                                                widget.challengeParticipation,
                                            challenge: widget.challenge,
                                            challengeDailyTrackings:
                                                widget.challengeDailyTrackings,
                                            challengeColor: challengeColor,
                                            canOpenDayBoxes: false,
                                            displayTitle: false,
                                            previewMode: widget.previewMode,
                                          ),
                                  ],
                                ],
                              ),
                              if (!isLargeScreen &&
                                  widget.challengeParticipation != null) ...[
                                const SizedBox(height: 8),
                                widget.challenge.startDate != null
                                    ? DailyTrackingCarouselWithStartDateWidget(
                                        challengeParticipation:
                                            widget.challengeParticipation,
                                        challenge: widget.challenge,
                                        challengeDailyTrackings:
                                            widget.challengeDailyTrackings,
                                        challengeColor: challengeColor,
                                        canOpenDayBoxes: false,
                                        displayTitle: false,
                                        previewMode: widget.previewMode,
                                      )
                                    : DailyTrackingCarouselWithoutStartDateWidget(
                                        challengeParticipation:
                                            widget.challengeParticipation,
                                        challenge: widget.challenge,
                                        challengeDailyTrackings:
                                            widget.challengeDailyTrackings,
                                        challengeColor: challengeColor,
                                        canOpenDayBoxes: false,
                                        displayTitle: false,
                                        previewMode: widget.previewMode,
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
                              child: GestureDetector(
                                onLongPressStart: (details) async {
                                  final offset = details.globalPosition;

                                  if (widget.challengeParticipation != null) {
                                    showMenu(
                                      context: context,
                                      position: RelativeRect.fromLTRB(
                                        offset.dx,
                                        offset.dy,
                                        MediaQuery.of(context).size.width -
                                            offset.dx,
                                        MediaQuery.of(context).size.height -
                                            offset.dy,
                                      ),
                                      items: [
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .delete),
                                        ),
                                      ],
                                    ).then(
                                      (value) {
                                        _quitChallenge();
                                      },
                                    );
                                  }
                                },
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
