import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';
import 'package:reallystick/features/private_messages/presentation/widgets/status_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

class DiscussionWidget extends StatelessWidget {
  final PrivateDiscussion discussion;

  const DiscussionWidget({super.key, required this.discussion});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;

    final userLocale = profileState.profile!.locale;

    if (userState is UsersLoaded) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.goNamed(
            'discussion',
            pathParameters: {
              'discussionId': discussion.id,
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: discussion.unseenMessages == 0
                ? null
                : Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: discussion.unseenMessages == 0
                ? []
                : [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userState.users[discussion.recipientId]?.username ??
                            AppLocalizations.of(context)!.unknown,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      if (discussion.hasBlocked) ...[
                        Text(AppLocalizations.of(context)!.youBlockedThisUser)
                      ] else ...[
                        Text(
                          discussion.lastMessage?.content
                                  .replaceAll('\\n', '\n') ??
                              "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ]
                    ],
                  ),
                ),
                if (discussion.unseenMessages > 0 ||
                    discussion.lastMessage != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (discussion.lastMessage != null)
                        Text(
                          discussion.lastMessage!.updateAt == null
                              ? DateFormat.Hm()
                                  .format(discussion.lastMessage!.createdAt)
                              : AppLocalizations.of(context)!.editedAt(
                                  DateFormat.yMEd(userLocale).add_Hm().format(
                                      discussion.lastMessage!.updateAt!)),
                          style: TextStyle(
                            color: context.colors.hint,
                            fontSize: 12,
                          ),
                        ),
                      if (discussion.unseenMessages > 0)
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              discussion.unseenMessages > 99
                                  ? '99+'
                                  : '${discussion.unseenMessages}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      if (discussion.lastMessage != null &&
                          discussion.lastMessage!.creator ==
                              profileState.profile!.id)
                        StatusWidget(isSeen: discussion.lastMessage!.seen)
                    ],
                  )
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
