import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';
import 'package:reallystick/features/private_messages/presentation/widgets/status_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

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
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        userState.getUsername(context, discussion.recipientId),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (discussion.unseenMessages > 0 ||
                        discussion.lastMessage != null)
                      Row(
                        children: [
                          if (discussion.lastMessage != null)
                            Text(
                              () {
                                final message = discussion.lastMessage!;
                                final displayDate =
                                    message.updateAt ?? message.createdAt;
                                final isToday =
                                    displayDate.isSameDate(DateTime.now());

                                if (message.updateAt == null) {
                                  return isToday
                                      ? DateFormat.Hm()
                                          .format(message.createdAt)
                                      : DateFormat.yMEd(userLocale)
                                          .add_Hm()
                                          .format(message.createdAt);
                                } else {
                                  if (isToday) {
                                    return AppLocalizations.of(context)!
                                        .editedAt(DateFormat.Hm()
                                            .format(message.updateAt!));
                                  } else {
                                    return DateFormat.yMEd(userLocale)
                                        .add_Hm()
                                        .format(message.updateAt!);
                                  }
                                }
                              }(),
                              style: TextStyle(
                                color: context.colors.hint,
                                fontSize: 12,
                              ),
                            ),
                          if (discussion.unseenMessages > 0) ...[
                            SizedBox(width: 5),
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
                          ],
                          if (discussion.lastMessage != null &&
                              discussion.lastMessage!.creator ==
                                  profileState.profile!.id) ...[
                            SizedBox(width: 5),
                            StatusWidget(isSeen: discussion.lastMessage!.seen)
                          ],
                        ],
                      )
                  ],
                ),
                SizedBox(height: 5),
                if (discussion.hasBlocked) ...[
                  Text(AppLocalizations.of(context)!.youBlockedThisUser)
                ] else if (discussion.lastMessage != null) ...[
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: Text(
                      discussion.lastMessage!.deleted
                          ? AppLocalizations.of(context)!.messageDeletedError
                          : discussion.lastMessage!.content,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                ]
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
