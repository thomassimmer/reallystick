import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_states.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/reply/reply_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/reply/reply_states.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_states.dart';
import 'package:reallystick/features/public_messages/presentation/screens/confirm_message_deletion_modal.dart';
import 'package:reallystick/features/public_messages/presentation/screens/create_message_report_modal.dart';
import 'package:reallystick/features/public_messages/presentation/widgets/creation_date_widget.dart';
import 'package:reallystick/features/public_messages/presentation/widgets/message_deleted_widget.dart';
import 'package:reallystick/features/public_messages/presentation/widgets/message_not_found_widget.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

class MessageWidget extends StatelessWidget {
  final String threadId;
  final String messageId;
  final Color color;
  final String? habitId;
  final String? challengeId;
  final bool withReplies;

  const MessageWidget({
    Key? key,
    required this.threadId,
    required this.messageId,
    required this.color,
    required this.habitId,
    required this.challengeId,
    required this.withReplies,
  }) : super(key: key);

  void _likeMessage(
      BuildContext context, bool hasLikedMessage, PublicMessage message) {
    if (hasLikedMessage) {
      BlocProvider.of<PublicMessageBloc>(context)
          .add(DeletePublicMessageLikeEvent(
        messageId: messageId,
      ));
    } else {
      BlocProvider.of<PublicMessageBloc>(context)
          .add(CreatePublicMessageLikeEvent(
        message: message,
      ));
    }
  }

  void _showAddReportBottomSheet(
    BuildContext context,
    PublicMessage message,
  ) {
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
            children: [
              CreateMessageReportModal(
                message: message,
              )
            ],
          ),
        );
      },
    );
  }

  void _showConfirmDeleteBottomSheet(
    BuildContext context,
    PublicMessage message,
  ) {
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
            children: [
              ConfirmMessageDeletionModal(
                message: message,
                deletedByAdmin: false,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;
    final publicMessageState = context.watch<PublicMessageBloc>().state;
    final privateDiscussionState = context.watch<PrivateDiscussionBloc>().state;
    final threadState = context.watch<ThreadBloc>().state;
    final replyState = context.watch<ReplyBloc>().state;

    if (userState is UsersLoaded &&
        publicMessageState is PublicMessagesLoaded &&
        profileState is ProfileAuthenticated &&
        threadState is ThreadLoaded &&
        replyState is ReplyLoaded) {
      final userLocale = profileState.profile.locale;

      PublicMessage? message = publicMessageState.threads
              .where((m) => m.id == messageId)
              .firstOrNull ??
          threadState.replies.where((m) => m.id == messageId).firstOrNull ??
          replyState.replies.where((m) => m.id == messageId).firstOrNull ??
          replyState.parents.where((m) => m.id == messageId).firstOrNull ??
          (replyState.reply != null && replyState.reply!.id == messageId
              ? replyState.reply
              : null) ??
          publicMessageState.likedMessages
              .where((m) => m.id == messageId)
              .firstOrNull ??
          publicMessageState.writtenMessages
              .where((m) => m.id == messageId)
              .firstOrNull ??
          publicMessageState.userReportedMessages
              .where((m) => m.id == messageId)
              .firstOrNull ??
          publicMessageState.allReportedMessages
              .where((m) => m.id == messageId)
              .firstOrNull;

      if (message == null) {
        return MessageNotFoundWidget();
      }

      if (message.deletedByAdmin || message.deletedByCreator) {
        return MessageDeletedWidget();
      }

      final replies = message.repliesTo == null
          ? threadState.replies.where((m) => m.repliesTo == messageId).toList()
          : replyState.replies.where((m) => m.repliesTo == messageId).toList();

      replies.sort((a, b) {
        if ((a.deletedByAdmin || a.deletedByCreator) &&
            (b.deletedByAdmin || b.deletedByCreator)) {
          return 0;
        }

        // Deleted messages always come last
        if (a.deletedByAdmin || a.deletedByCreator) {
          return 1;
        }
        if (b.deletedByAdmin || b.deletedByCreator) {
          return -1;
        }

        if (b.likeCount != a.likeCount) {
          return b.likeCount - a.likeCount;
        }

        return b.createdAt.compareTo(a.createdAt);
      });

      final hasLikedMessage = publicMessageState.likedMessages
          .where((m) => m.id == messageId)
          .toList()
          .isNotEmpty;

      PrivateDiscussion? discussion = privateDiscussionState.discussions.values
          .where((d) => d.recipientId == message.creator)
          .firstOrNull;

      return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => {
                    if (discussion != null)
                      {
                        context.goNamed(
                          'discussion',
                          pathParameters: {
                            'discussionId': discussion.id,
                          },
                        )
                      }
                    else
                      {
                        context.goNamed(
                          'newDiscussion',
                          pathParameters: {'recipientId': message.creator},
                        )
                      }
                  },
                  child: Text(
                    userState.users[message.creator]?.username ??
                        AppLocalizations.of(context)!.unknown,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DateWidget(
                  datetime: message.createdAt,
                  userLocale: userLocale,
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(message.content),
            SizedBox(height: 15),
            Row(
              children: [
                InkWell(
                  onTap: () => _likeMessage(context, hasLikedMessage, message),
                  child: Icon(
                    hasLikedMessage ? Icons.favorite : Icons.favorite_border,
                    color: hasLikedMessage ? context.colors.error : color,
                    size: 15,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  message.likeCount.toString(),
                  style: TextStyle(
                    color: color,
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.comment_outlined,
                  color: color,
                  size: 15,
                ),
                SizedBox(width: 5),
                Text(
                  message.replyCount.toString(),
                  style: TextStyle(
                    color: color,
                  ),
                ),
                if (message.creator == profileState.profile.id) ...[
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () =>
                        _showConfirmDeleteBottomSheet(context, message),
                    child: Icon(
                      Icons.delete_outline,
                      color: color,
                      size: 15,
                    ),
                  ),
                ],
                Spacer(),
                InkWell(
                  onTap: () => _showAddReportBottomSheet(context, message),
                  child: Icon(
                    Icons.warning,
                    color: color,
                    size: 15,
                  ),
                ),
              ],
            ),
            if (withReplies && replies.isNotEmpty) ...[
              SizedBox(height: 20),
              for (final reply in replies) ...[
                Divider(color: color),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => {
                    if (challengeId != null)
                      {
                        context.goNamed(
                          'challengeThreadReply',
                          pathParameters: {
                            'challengeId': challengeId!,
                            'messageId': reply.id,
                            'threadId': threadId,
                          },
                        )
                      }
                    else if (habitId != null)
                      {
                        context.goNamed(
                          'habitThreadReply',
                          pathParameters: {
                            'habitId': habitId!,
                            'messageId': reply.id,
                            'threadId': threadId,
                          },
                        )
                      }
                  },
                  child: MessageWidget(
                    color: color,
                    messageId: reply.id,
                    habitId: habitId,
                    challengeId: challengeId,
                    threadId: threadId,
                    withReplies: false,
                  ),
                ),
              ],
            ],
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }
}
