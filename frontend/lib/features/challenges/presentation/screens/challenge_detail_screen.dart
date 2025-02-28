import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/constants/icons.dart';
import 'package:reallystick/core/presentation/screens/loading_screen.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/screens/add_daily_tracking_modal.dart';
import 'package:reallystick/features/challenges/presentation/screens/challenge_not_found_screen.dart';
import 'package:reallystick/features/challenges/presentation/screens/duplicate_challenge_modal.dart';
import 'package:reallystick/features/challenges/presentation/widgets/analytics_carousel_widget.dart';
import 'package:reallystick/features/challenges/presentation/widgets/challenge_discussion_list_widget.dart';
import 'package:reallystick/features/challenges/presentation/widgets/daily_tracking_carousel_widget.dart';
import 'package:reallystick/features/challenges/presentation/widgets/list_of_concerned_habits.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/screens/color_picker_modal.dart';
import 'package:reallystick/features/habits/presentation/widgets/add_activity_button.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:share_plus/share_plus.dart';

class ChallengeDetailsScreen extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailsScreen({
    Key? key,
    required this.challengeId,
  }) : super(key: key);

  @override
  ChallengeDetailsScreenState createState() => ChallengeDetailsScreenState();
}

class ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  void _showAddDailyTrackingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 600,
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Wrap(
            children: [AddDailyTrackingModal(challengeId: widget.challengeId)],
          ),
        );
      },
    );
  }

  void _quitChallenge(String challengeParticipationId) {
    final deleteChallengeParticipationEvent = DeleteChallengeParticipationEvent(
      challengeParticipationId: challengeParticipationId,
    );
    context.read<ChallengeBloc>().add(deleteChallengeParticipationEvent);
  }

  void _deleteChallenge(String challengeId, String? challengeParticipationId) {
    final deleteChallengeEvent = DeleteChallengeEvent(
      challengeId: challengeId,
      challengeParticipationId: challengeParticipationId,
    );
    context.read<ChallengeBloc>().add(deleteChallengeEvent);
  }

  void _openColorPicker(String challengeParticipationId) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 600,
      ),
      builder: (BuildContext context) {
        return ColorPickerModal(
          onColorSelected: (selectedColor) {
            final updateChallengeParticipationEvent =
                UpdateChallengeParticipationEvent(
              challengeParticipationId: challengeParticipationId,
              color: selectedColor.toShortString(),
              startDate: DateTime.now(), // TODO : Modal to create
            );
            context
                .read<ChallengeBloc>()
                .add(updateChallengeParticipationEvent);

            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _openDuplicateChallengeModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 600,
      ),
      builder: (BuildContext context) {
        return DuplicateChallengeModal(
          challengeId: widget.challengeId,
        );
      },
    );
  }

  void _joinChallenge() {
    final createChallengeParticipationEvent = CreateChallengeParticipationEvent(
      challengeId: widget.challengeId,
      startDate: DateTime.now(), // TODO : Modal to create
    );
    context.read<ChallengeBloc>().add(createChallengeParticipationEvent);
  }

  void _shareChallenge() async {
    final String relativeUri = context.namedLocation(
      'challengeDetails',
      pathParameters: {'challengeId': widget.challengeId},
    );

    final String baseUrl = dotenv.env['API_BASE_URL'] ?? "";
    final Uri fullUri = Uri.parse('$baseUrl$relativeUri');

    final String message =
        AppLocalizations.of(context)!.shareChallengeText(fullUri.toString());
    final String subject = AppLocalizations.of(context)!.shareChallengeSubject;

    try {
      await Share.share(message, subject: subject);
    } catch (e) {
      print(e);
    }
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
          final userLocale = profileState.profile.locale;

          final challenge = challengeState.challenges[widget.challengeId];

          if (challenge == null) {
            if (challengeState.notFoundChallenge == widget.challengeId) {
              return ChallengeNotFoundScreen();
            } else {
              context
                  .read<ChallengeBloc>()
                  .add(GetChallengeEvent(challengeId: widget.challengeId));
              return LoadingScreen();
            }
          }

          final challengeParticipation = challengeState.challengeParticipations
              .where((hp) => hp.challengeId == widget.challengeId)
              .firstOrNull;
          var challengeDailyTrackings =
              challengeState.challengeDailyTrackings[widget.challengeId];

          if (challengeDailyTrackings == null) {
            BlocProvider.of<ChallengeBloc>(context).add(
              GetChallengeDailyTrackingsEvent(challengeId: widget.challengeId),
            );
            challengeDailyTrackings = [];
          }

          final name = getRightTranslationFromJson(
            challenge.name,
            userLocale,
          );

          final description = getRightTranslationFromJson(
            challenge.description,
            userLocale,
          );

          final challengeColor = AppColorExtension.fromString(
            challengeParticipation != null ? challengeParticipation.color : "",
          ).color;

          final challengeStatistics =
              challengeState.challengeStatistics[widget.challengeId]!;

          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: getIconWidget(
                      iconString: challenge.icon,
                      size: 30,
                      color: challengeColor,
                    ),
                  ),
                  SelectableText(
                    name,
                    style: TextStyle(color: challengeColor),
                  ),
                ],
              ),
              actions: [
                if (challenge.creator == profileState.profile.id ||
                    challengeParticipation != null)
                  PopupMenuButton<String>(
                    color: context.colors.backgroundDark,
                    onSelected: (value) async {
                      if (value == 'quit') {
                        _quitChallenge(challengeParticipation!.id);
                      } else if (value == 'change_color') {
                        _openColorPicker(challengeParticipation!.id);
                      } else if (value == 'update') {
                        context.goNamed(
                          'updateChallenge',
                          pathParameters: {'challengeId': challenge.id},
                        );
                      } else if (value == 'delete') {
                        _deleteChallenge(
                          challenge.id,
                          challengeParticipation?.id,
                        );
                        context.goNamed(
                          'challenges',
                        );
                      } else if (value == 'share') {
                        _shareChallenge();
                      } else if (value == 'duplicate') {
                        _openDuplicateChallengeModal();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      if (challengeParticipation != null) ...[
                        PopupMenuItem(
                          value: 'quit',
                          child: Text(
                              AppLocalizations.of(context)!.quitThisChallenge),
                        ),
                        PopupMenuItem(
                          value: 'change_color',
                          child:
                              Text(AppLocalizations.of(context)!.changeColor),
                        ),
                        PopupMenuItem(
                          value: 'share',
                          child: Text(AppLocalizations.of(context)!.share),
                        ),
                      ],
                      PopupMenuItem(
                        value: "duplicate",
                        child: Text(AppLocalizations.of(context)!.duplicate),
                      ),
                      if (challenge.creator == profileState.profile.id) ...[
                        PopupMenuItem(
                          value: 'update',
                          child:
                              Text(AppLocalizations.of(context)!.editChallenge),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                              AppLocalizations.of(context)!.deleteChallenge),
                        ),
                      ]
                    ],
                  ),
              ],
            ),
            floatingActionButton: challenge.creator ==
                        profileState.profile.id &&
                    challengeParticipation != null
                ? AddActivityButton(
                    action: _showAddDailyTrackingBottomSheet,
                    color: challengeColor,
                    label: AppLocalizations.of(context)!.addDailyObjective,
                  )
                : challengeParticipation == null
                    ? FloatingActionButton.extended(
                        onPressed: _joinChallenge,
                        icon: Icon(Icons.login),
                        label: Text(
                            AppLocalizations.of(context)!.joinThisChallenge),
                        backgroundColor: context.colors.primary,
                        extendedTextStyle: TextStyle(
                            letterSpacing: 1, fontFamily: 'Montserrat'),
                      )
                    : null,
            body: RefreshIndicator(
              onRefresh: _pullRefresh,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: ListView(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: challengeColor.withAlpha(155),
                        border: Border.all(width: 1, color: challengeColor),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.createdBy(
                                    challengeStatistics.creatorUsername),
                                style: TextStyle(
                                    color: context.colors.textOnPrimary),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 16),
                              Text(
                                description,
                                style: TextStyle(
                                    color: context.colors.textOnPrimary),
                              ),
                            ],
                          )),
                    ),
                    SizedBox(height: 30),
                    ListOfConcernedHabits(
                      challengeColor: challengeColor,
                      challengeId: widget.challengeId,
                    ),
                    SizedBox(height: 30),
                    AnalyticsCarouselWidget(
                      challengeColor: challengeColor,
                      challengeId: challenge.id,
                    ),
                    SizedBox(height: 30),
                    if (challenge.creator == profileState.profile.id ||
                        challengeParticipation != null) ...[
                      DailyTrackingCarouselWidget(
                        challengeDailyTrackings: challengeDailyTrackings,
                        challengeColor: challengeColor,
                        challengeId: widget.challengeId,
                        canOpenDayBoxes: true,
                        displayTitle: true,
                      ),
                      SizedBox(height: 30),
                    ],
                    ChallengeDiscussionListWidget(color: challengeColor),
                    SizedBox(height: 72),
                  ],
                ),
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
