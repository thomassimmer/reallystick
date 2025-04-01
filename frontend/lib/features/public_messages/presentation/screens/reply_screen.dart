import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/presentation/screens/loading_screen.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_column.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/ui/extensions.dart';
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
import 'package:reallystick/features/public_messages/presentation/blocs/reply/reply_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/reply/reply_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/reply/reply_states.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_states.dart';
import 'package:reallystick/features/public_messages/presentation/widgets/message_widget.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

class ReplyScreen extends StatefulWidget {
  final String threadId;
  final String messageId;
  final String? habitId;
  final String? challengeId;
  final String? challengeParticipationId;

  const ReplyScreen({
    super.key,
    required this.threadId,
    required this.messageId,
    required this.habitId,
    required this.challengeId,
    required this.challengeParticipationId,
  });

  @override
  ReplyScreenState createState() => ReplyScreenState();
}

class ReplyScreenState extends State<ReplyScreen> {
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
    BlocProvider.of<ReplyBloc>(context).add(
      InitializeReplyEvent(
        messageId: widget.messageId,
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
          repliesTo: widget.messageId,
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
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = checkIfLargeScreen(context);

    final profileState = context.watch<ProfileBloc>().state;
    final replyState = context.watch<ReplyBloc>().state;

    if (profileState is ProfileAuthenticated &&
        replyState is ReplyLoaded &&
        (replyState.reply == null ||
            replyState.reply!.id != widget.messageId)) {
      BlocProvider.of<ReplyBloc>(context).add(
        InitializeReplyEvent(
          messageId: widget.messageId,
        ),
      );
    }

    return Builder(
      builder: (context) {
        final profileState = context.watch<ProfileBloc>().state;
        final challengeState = context.watch<ChallengeBloc>().state;
        final habitState = context.watch<HabitBloc>().state;
        final publicMessageState = context.watch<PublicMessageBloc>().state;
        final userState = context.watch<UserBloc>().state;
        final threadState = context.watch<ThreadBloc>().state;
        final replyState = context.watch<ReplyBloc>().state;

        if (userState is UsersLoaded &&
            profileState is ProfileAuthenticated &&
            challengeState is ChallengesLoaded &&
            publicMessageState is PublicMessagesLoaded &&
            habitState is HabitsLoaded &&
            threadState is ThreadLoaded &&
            replyState is ReplyLoaded) {
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
                isLargeScreen ? habit.longName : habit.shortName,
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
                  .where((m) => m.id == widget.messageId)
                  .firstOrNull ??
              threadState.replies
                  .where((m) => m.id == widget.messageId)
                  .firstOrNull ??
              replyState.reply;

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
                padding: EdgeInsets.only(bottom: 16),
                child: FullWidthColumn(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (replyState.parents.isNotEmpty) ...[
                              for (final parent in replyState.parents) ...[
                                InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => {
                                    if (parent.repliesTo == null)
                                      {
                                        if (widget.challengeId != null)
                                          {
                                            context.goNamed(
                                              'challengeThread',
                                              pathParameters: {
                                                'challengeId':
                                                    widget.challengeId!,
                                                'challengeParticipationId':
                                                    'null',
                                                'threadId': widget.threadId,
                                              },
                                            )
                                          }
                                        else if (widget.habitId != null)
                                          {
                                            context.goNamed(
                                              'habitThread',
                                              pathParameters: {
                                                'habitId': widget.habitId!,
                                                'threadId': widget.threadId,
                                              },
                                            )
                                          }
                                      }
                                    else
                                      {
                                        if (widget.challengeId != null)
                                          {
                                            context.goNamed(
                                              'challengeThreadReply',
                                              pathParameters: {
                                                'challengeId':
                                                    widget.challengeId!,
                                                'challengeParticipationId':
                                                    'null',
                                                'messageId': parent.id,
                                                'threadId': widget.threadId,
                                              },
                                            )
                                          }
                                        else if (widget.habitId != null)
                                          {
                                            context.goNamed(
                                              'habitThreadReply',
                                              pathParameters: {
                                                'habitId': widget.habitId!,
                                                'messageId': parent.id,
                                                'threadId': widget.threadId,
                                              },
                                            )
                                          }
                                      }
                                  },
                                  child: MessageWidget(
                                    color: color,
                                    messageId: parent.id,
                                    habitId: widget.habitId,
                                    challengeId: widget.challengeId,
                                    challengeParticipationId:
                                        widget.challengeParticipationId,
                                    threadId: widget.threadId,
                                    withReplies: false,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Divider(color: color),
                                SizedBox(height: 20),
                              ],
                            ],
                            MessageWidget(
                              messageId: widget.messageId,
                              color: color,
                              habitId: widget.habitId,
                              challengeId: widget.challengeId,
                              challengeParticipationId:
                                  widget.challengeParticipationId,
                              threadId: widget.threadId,
                              withReplies: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (message != null) ...[
                      CustomMessageInput(
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
