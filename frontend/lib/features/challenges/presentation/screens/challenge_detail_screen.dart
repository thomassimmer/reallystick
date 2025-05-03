import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/presentation/screens/loading_screen.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_list_view.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/open_url.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/helpers/challenge_date.dart';
import 'package:reallystick/features/challenges/presentation/screens/add_daily_tracking_modal.dart';
import 'package:reallystick/features/challenges/presentation/screens/challenge_not_found_screen.dart';
import 'package:reallystick/features/challenges/presentation/screens/change_participation_start_date_modal.dart';
import 'package:reallystick/features/challenges/presentation/screens/duplicate_challenge_modal.dart';
import 'package:reallystick/features/challenges/presentation/screens/finish_challenge_modal.dart';
import 'package:reallystick/features/challenges/presentation/widgets/analytics_carousel_widget.dart';
import 'package:reallystick/features/challenges/presentation/widgets/daily_tracking_carousel_with_start_date_widget.dart';
import 'package:reallystick/features/challenges/presentation/widgets/daily_tracking_carousel_without_start_date_widget.dart';
import 'package:reallystick/features/challenges/presentation/widgets/list_of_concerned_habits.dart';
import 'package:reallystick/features/challenges/presentation/widgets/set_reminder_modal.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/screens/color_picker_modal.dart';
import 'package:reallystick/features/habits/presentation/widgets/add_activity_button.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_events.dart';
import 'package:reallystick/features/public_messages/presentation/widgets/discussion_list_widget.dart';
import 'package:reallystick/i18n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class ChallengeDetailsScreen extends StatefulWidget {
  final String challengeId;
  final String? challengeParticipationId;
  final bool previewMode;
  final bool previewForDailyObjectives;
  final bool previewForDiscussion;

  const ChallengeDetailsScreen({
    super.key,
    required this.challengeId,
    required this.challengeParticipationId,
    required this.previewMode,
    required this.previewForDailyObjectives,
    required this.previewForDiscussion,
  });

  @override
  ChallengeDetailsScreenState createState() => ChallengeDetailsScreenState();
}

class ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  ScrollController controller = ScrollController();
  bool _modalOpened = false;

  void _showAddDailyTrackingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                AddDailyTrackingModal(challengeId: widget.challengeId)
              ],
            ),
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

  void _openColorPicker(ChallengeParticipation challengeParticipation) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
      builder: (BuildContext context) {
        return ColorPickerModal(
          onColorSelected: (selectedColor) {
            final updateChallengeParticipationEvent =
                UpdateChallengeParticipationEvent(
              challengeParticipationId: challengeParticipation.id,
              color: selectedColor.toShortString(),
              startDate: DateTime
                  .now(), // TODO : Modal to create if user started this challenge before
              notificationsReminderEnabled:
                  challengeParticipation.notificationsReminderEnabled,
              reminderTime: challengeParticipation.reminderTime,
              reminderBody: challengeParticipation.reminderBody,
              finished: challengeParticipation.finished,
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

  void _showNotificationsReminderBottomSheet({
    required ChallengeParticipation challengeParticipation,
    required String challengeName,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                SetReminderModal(
                  challengeParticipation: challengeParticipation,
                  challengeName: challengeName,
                )
              ],
            ),
          ),
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
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
      builder: (BuildContext context) {
        return DuplicateChallengeModal(
          challengeId: widget.challengeId,
        );
      },
    );
  }

  Future<void> _openFinishChallengeModal({
    required ChallengeParticipation challengeParticipation,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
      builder: (BuildContext context) {
        return FinishChallengeModal(
          challengeId: widget.challengeId,
          challengeParticipation: challengeParticipation,
        );
      },
    );
  }

  void _openChangeChallengeParticipationStartDateModal({
    required ChallengeParticipation challengeParticipation,
    required String userLocale,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
      builder: (BuildContext context) {
        return ChangeParticipationStartDateModal(
          challengeId: widget.challengeId,
          challengeParticipation: challengeParticipation,
          userLocale: userLocale,
        );
      },
    );
  }

  void _joinChallenge() {
    final createChallengeParticipationEvent = CreateChallengeParticipationEvent(
      challengeId: widget.challengeId,
      startDate: DateTime.now(),
    );
    context.read<ChallengeBloc>().add(createChallengeParticipationEvent);
  }

  void _participateInChallengeAgain() {
    final createChallengeParticipationEvent = CreateChallengeParticipationEvent(
      challengeId: widget.challengeId,
      startDate: DateTime.now(),
    );
    context.read<ChallengeBloc>().add(createChallengeParticipationEvent);
  }

  void _shareChallenge() async {
    final String relativeUri = context.namedLocation(
      'challengeDetails',
      pathParameters: {
        'challengeId': widget.challengeId,
        'challengeParticipationId': 'null'
      },
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
  void initState() {
    super.initState();

    _modalOpened = false;

    if (widget.previewMode) {
      if (widget.previewForDailyObjectives || widget.previewForDiscussion) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            Future.delayed(
              Duration(milliseconds: 50),
              () {
                _scrollToChart();
              },
            );
          },
        );
      }
    } else {
      BlocProvider.of<PublicMessageBloc>(context).add(
        PublicMessageInitializeEvent(
          habitId: null,
          challengeId: widget.challengeId,
        ),
      );
    }
  }

  void _scrollToChart() {
    if (controller.hasClients) {
      controller.jumpTo(controller.position.maxScrollExtent);
    } else {
      Timer(Duration(milliseconds: 400), () => _scrollToChart());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChallengeBloc, ChallengeState>(
      listener: (context, state) {
        if (state is ChallengesLoaded && state.message is SuccessMessage) {
          final message = state.message as SuccessMessage;

          if (message.messageKey == "challengeParticipationCreated") {
            final newChallengeParticipation =
                state.newlyCreatedChallengeParticipation;

            if (newChallengeParticipation != null) {
              context.goNamed(
                'challengeDetails',
                pathParameters: {
                  'challengeId': widget.challengeId,
                  'challengeParticipationId': newChallengeParticipation.id,
                },
              );
            }
          }
        }
      },
      child: Builder(
        builder: (context) {
          final profileState = widget.previewMode
              ? getProfileAuthenticatedForPreview(context)
              : context.watch<ProfileBloc>().state;
          final challengeState = widget.previewMode
              ? getChallengeStateForPreview(context)
              : context.watch<ChallengeBloc>().state;

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

            ChallengeParticipation? challengeParticipation;

            // If a participation id was passed, use it, otherwise take the last participation
            if (widget.challengeParticipationId != null) {
              challengeParticipation = challengeState.challengeParticipations
                  .where((hp) => hp.id == widget.challengeParticipationId)
                  .firstOrNull;
            } else {
              final ongoingChallengeParticipationsForThisChallenge =
                  challengeState.challengeParticipations
                      .where((hp) =>
                          hp.challengeId == widget.challengeId && !hp.finished)
                      .toList();

              challengeParticipation =
                  ongoingChallengeParticipationsForThisChallenge.firstOrNull;
            }

            var challengeDailyTrackings =
                challengeState.challengeDailyTrackings[widget.challengeId];

            if (challengeDailyTrackings == null) {
              BlocProvider.of<ChallengeBloc>(context).add(
                GetChallengeDailyTrackingsEvent(
                    challengeId: widget.challengeId),
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
              challengeParticipation != null
                  ? challengeParticipation.color
                  : "",
            ).color;

            final challengeStatistics =
                challengeState.challengeStatistics[widget.challengeId];

            if (challengeParticipation != null && !_modalOpened) {
              final finished = checkIfChallengeIsFinished(
                challengeDailyTrackings: challengeDailyTrackings,
                challengeStartDate: challenge.startDate,
                challengeParticipation: challengeParticipation,
              );

              if (finished && !challengeParticipation.finished) {
                if (ModalRoute.of(context)?.isCurrent ?? true) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) {
                      _modalOpened = true;
                      _openFinishChallengeModal(
                        challengeParticipation: challengeParticipation!,
                      ).then(
                        (_) {
                          _modalOpened = false;
                        },
                      );
                    },
                  );
                }
              }
            }
            return Scaffold(
              appBar: CustomAppBar(
                title: Text(
                  name,
                  style: context.typographies.headingSmall.copyWith(
                    color: challengeColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
                          _openColorPicker(challengeParticipation!);
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
                        } else if (value == 'set_reminder') {
                          _showNotificationsReminderBottomSheet(
                            challengeParticipation: challengeParticipation!,
                            challengeName: name,
                          );
                        } else if (value == 'change_participation_start_date') {
                          _openChangeChallengeParticipationStartDateModal(
                            challengeParticipation: challengeParticipation!,
                            userLocale: userLocale,
                          );
                        } else if (value == "start_again") {
                          _participateInChallengeAgain();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        if (challengeParticipation != null) ...[
                          if (challengeParticipation.finished)
                            PopupMenuItem(
                              value: 'start_again',
                              child: Text(AppLocalizations.of(context)!
                                  .participateAgain),
                            ),
                          PopupMenuItem(
                            value: 'quit',
                            child: Text(
                              challengeParticipation.finished
                                  ? AppLocalizations.of(context)!
                                      .deleteChallengeParticipation
                                  : AppLocalizations.of(context)!
                                      .quitThisChallenge,
                            ),
                          ),
                          if (!challengeParticipation.finished)
                            PopupMenuItem(
                              value: 'change_participation_start_date',
                              child: Text(
                                AppLocalizations.of(context)!
                                    .changeChallengeParticipationStartDate,
                              ),
                            ),
                          PopupMenuItem(
                            value: 'change_color',
                            child:
                                Text(AppLocalizations.of(context)!.changeColor),
                          ),
                          PopupMenuItem(
                            value: 'set_reminder',
                            child: Text(
                                AppLocalizations.of(context)!.notifications),
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
                            child: Text(
                                AppLocalizations.of(context)!.editChallenge),
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
                      label: null,
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
                child: FullWidthListView(
                  controller: controller,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                challenge.icon,
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (challengeStatistics != null) ...[
                                Text(
                                  challenge.startDate == null
                                      ? AppLocalizations.of(context)!.createdBy(
                                          challengeStatistics.creatorUsername,
                                        )
                                      : AppLocalizations.of(context)!
                                          .createdByStartsOn(
                                          challengeStatistics.creatorUsername,
                                          DateFormat.yMMMd(
                                                  userLocale.toString())
                                              .format(challenge.startDate!),
                                        ),
                                  style: TextStyle(
                                      color: context.colors.textOnPrimary),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 16),
                              ],
                              if (challengeParticipation != null) ...[
                                Text(
                                  AppLocalizations.of(context)!.joinedOn(
                                    DateFormat.yMMMd(userLocale).format(
                                      challengeParticipation.startDate,
                                    ),
                                  ),
                                  style: TextStyle(
                                      color: context.colors.textOnPrimary),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 16),
                              ],
                              Markdown(
                                selectable: true,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.all(0),
                                data: AppLocalizations.of(context)!
                                    .descriptionWithTwoPoints(description),
                                onTapLink: markdownTapLinkCallback,
                                styleSheet: MarkdownStyleSheet(
                                    textAlign: WrapAlignment.center),
                              )
                            ],
                          )),
                    ),
                    SizedBox(height: 30),
                    ListOfConcernedHabits(
                      challengeColor: challengeColor,
                      challengeId: widget.challengeId,
                      previewMode: widget.previewMode,
                    ),
                    SizedBox(height: 30),
                    AnalyticsCarouselWidget(
                      challengeColor: challengeColor,
                      challengeId: challenge.id,
                      previewMode: widget.previewMode,
                    ),
                    SizedBox(height: 30),
                    challenge.startDate != null
                        ? DailyTrackingCarouselWithStartDateWidget(
                            challengeParticipation: challengeParticipation,
                            challengeDailyTrackings: challengeDailyTrackings,
                            challengeColor: challengeColor,
                            challenge: challenge,
                            canOpenDayBoxes: true,
                            displayTitle: true,
                            previewMode: widget.previewMode,
                          )
                        : DailyTrackingCarouselWithoutStartDateWidget(
                            challengeParticipation: challengeParticipation,
                            challengeDailyTrackings: challengeDailyTrackings,
                            challengeColor: challengeColor,
                            challenge: challenge,
                            canOpenDayBoxes: true,
                            displayTitle: true,
                            previewMode: widget.previewMode,
                          ),
                    SizedBox(height: 30),
                    DiscussionListWidget(
                      color: challengeColor,
                      habitId: null,
                      challengeId: widget.challengeId,
                      challengeParticipationId: challengeParticipation?.id,
                      previewMode: widget.previewMode,
                    ),
                    SizedBox(height: 72),
                  ],
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
