import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class ThreadWidget extends StatelessWidget {
  final PublicMessage thread;
  final Color color;
  final String? habitId;
  final String? challengeId;
  final String? challengeParticipationId;
  final bool previewMode;

  const ThreadWidget({
    super.key,
    required this.thread,
    required this.color,
    required this.habitId,
    required this.challengeId,
    required this.challengeParticipationId,
    required this.previewMode,
  });

  @override
  Widget build(BuildContext context) {
    final userState = previewMode
        ? getUserStateForPreview(context)
        : context.watch<UserBloc>().state;
    final publicMessageState = previewMode
        ? getPublicMessagesLoadedForPreview(context)
        : context.watch<PublicMessageBloc>().state;

    if (userState is UsersLoaded &&
        publicMessageState is PublicMessagesLoaded) {
      final hasLikedMessage = publicMessageState.likedMessages
          .where((m) => m.id == thread.id)
          .toList()
          .isNotEmpty;

      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (challengeId != null) {
            context.goNamed(
              'challengeThread',
              pathParameters: {
                'challengeId': challengeId!,
                'challengeParticipationId': challengeParticipationId ?? 'null',
                'threadId': thread.id,
              },
            );
          } else if (habitId != null) {
            context.goNamed(
              'habitThread',
              pathParameters: {
                'habitId': habitId!,
                'threadId': thread.id,
              },
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color.withAlpha(100)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      userState.users[thread.creator]?.username ??
                          AppLocalizations.of(context)!.unknown,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  thread.content,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      hasLikedMessage ? Icons.favorite : Icons.favorite_border,
                      color: hasLikedMessage ? context.colors.error : color,
                      size: 15,
                    ),
                    SizedBox(width: 5),
                    Text(
                      thread.likeCount.toString(),
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
                      thread.replyCount.toString(),
                      style: TextStyle(
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
