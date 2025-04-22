import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/presentation/screens/loading_screen.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_column.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/screens/challenge_not_found_screen.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';
import 'package:reallystick/features/habits/presentation/screens/habit_not_found_screen.dart';
import 'package:reallystick/features/private_messages/presentation/widgets/custom_message_input.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_states.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_creation/public_message_creation_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_creation/public_message_creation_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_states.dart';
import 'package:reallystick/features/public_messages/presentation/widgets/message_widget.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

class ThreadScreen extends StatefulWidget {
  final String threadId;
  final String? habitId;
  final String? challengeId;
  final String? challengeParticipationId;
  final bool previewMode;

  const ThreadScreen({
    super.key,
    required this.threadId,
    required this.habitId,
    required this.challengeId,
    required this.challengeParticipationId,
    required this.previewMode,
  });

  @override
  ThreadScreenState createState() => ThreadScreenState();
}

class ThreadScreenState extends State<ThreadScreen> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _contentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _contentController.dispose();

    super.dispose();
  }

  Future<void> _pullRefresh() async {
    BlocProvider.of<ThreadBloc>(context).add(
      InitializeThreadEvent(
        threadId: widget.threadId,
      ),
    );
    await Future.delayed(Duration(seconds: 2));
  }

  void _replyToMessage() {
    final publicMessageCreationFormBloc =
        context.read<PublicMessageCreationFormBloc>();

    publicMessageCreationFormBloc.add(
      PublicMessageCreationFormContentChangedEvent(_contentController.text),
    );

    Future.delayed(const Duration(milliseconds: 50), () {
      if (publicMessageCreationFormBloc.state.isValid) {
        final newMessageEvent = CreatePublicMessageEvent(
          habitId: widget.habitId,
          challengeId: widget.challengeId,
          repliesTo: widget.threadId,
          content: _contentController.text,
          threadId: widget.threadId,
        );

        if (mounted) {
          context.read<PublicMessageBloc>().add(newMessageEvent);
        }

        setState(() {
          _contentController.text = "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final profileState = widget.previewMode
            ? getProfileAuthenticatedForPreview(context)
            : context.watch<ProfileBloc>().state;
        final habitState = widget.previewMode
            ? getHabitsLoadedForPreview(context)
            : context.watch<HabitBloc>().state;
        final challengeState = widget.previewMode
            ? getChallengeStateForPreview(context)
            : context.watch<ChallengeBloc>().state;
        final publicMessageState = widget.previewMode
            ? getPublicMessagesLoadedForPreview(context)
            : context.watch<PublicMessageBloc>().state;
        final userState = widget.previewMode
            ? getUserStateForPreview(context)
            : context.watch<UserBloc>().state;
        final threadState = widget.previewMode
            ? getThreadStateForPreview(context)
            : context.watch<ThreadBloc>().state;

        if (profileState is ProfileAuthenticated &&
            threadState is ThreadLoaded &&
            (threadState.threadId == null ||
                threadState.threadId != widget.threadId)) {
          BlocProvider.of<ThreadBloc>(context).add(
            InitializeThreadEvent(
              threadId: widget.threadId,
            ),
          );
        }

        if (userState is UsersLoaded &&
            profileState is ProfileAuthenticated &&
            challengeState is ChallengesLoaded &&
            publicMessageState is PublicMessagesLoaded &&
            habitState is HabitsLoaded) {
          final userLocale = profileState.profile.locale;

          Color color = AppColorExtension.getRandomColor().color;
          String? name;

          if (widget.challengeId != null) {
            final challenge = challengeState.challenges[widget.challengeId];

            if (challenge == null) {
              if (challengeState.notFoundChallenge == widget.challengeId) {
                return ChallengeNotFoundScreen();
              } else {
                context
                    .read<ChallengeBloc>()
                    .add(GetChallengeEvent(challengeId: widget.challengeId!));
                return LoadingScreen();
              }
            } else {
              name = getRightTranslationFromJson(
                challenge.name,
                userLocale,
              );
            }

            final challengeParticipation = challengeState
                .challengeParticipations
                .where((hp) => hp.challengeId == widget.challengeId)
                .firstOrNull;

            if (challengeParticipation != null) {
              color = AppColorExtension.fromString(
                challengeParticipation.color,
              ).color;
            }
          } else if (widget.habitId != null) {
            final habit = habitState.habits[widget.habitId];

            if (habit == null) {
              return HabitNotFoundScreen();
            } else {
              name = getRightTranslationFromJson(
                habit.name,
                userLocale,
              );
            }

            final habitParticipation = habitState.habitParticipations
                .where((hp) => hp.habitId == widget.habitId)
                .firstOrNull;

            if (habitParticipation != null) {
              color = AppColorExtension.fromString(
                habitParticipation.color,
              ).color;
            }
          }

          final message = publicMessageState.threads
              .where((m) => m.id == widget.threadId)
              .firstOrNull;

          return Scaffold(
            appBar: CustomAppBar(
              title: Text(
                name ?? "",
                style: context.typographies.headingSmall.copyWith(
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            body: RefreshIndicator(
              onRefresh: _pullRefresh,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FullWidthColumn(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: MessageWidget(
                          messageId: widget.threadId,
                          color: color,
                          habitId: widget.habitId,
                          challengeId: widget.challengeId,
                          challengeParticipationId:
                              widget.challengeParticipationId,
                          threadId: widget.threadId,
                          withReplies: true,
                          previewMode: widget.previewMode,
                        ),
                      ),
                    ),
                    if (message != null) ...[
                      CustomMessageInput(
                        readOnly: widget.previewMode,
                        contentController: _contentController,
                        recipientUsername:
                            userState.users[message.creator]?.username,
                        onSendMessage: _replyToMessage,
                      )
                    ],
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
