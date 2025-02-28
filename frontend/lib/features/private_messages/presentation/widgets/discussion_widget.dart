import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

class DiscussionWidget extends StatelessWidget {
  final PrivateDiscussion discussion;

  const DiscussionWidget({Key? key, required this.discussion})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    final privateDiscussionState = context.watch<PrivateDiscussionBloc>().state;

    if (userState is UsersLoaded &&
        privateDiscussionState is PrivateDiscussionLoaded) {
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
              // border: Border.all(color: color.withAlpha(100)),
              // boxShadow: [
              //   BoxShadow(
              //     // color: color.withOpacity(0.2),
              //     blurRadius: 10,
              //   ),
              // ],
              // borderRadius: BorderRadius.circular(16),
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
                      userState.users[discussion.recipientId]?.username ??
                          AppLocalizations.of(context)!.unknown,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                if (discussion.hasBlocked) ...[
                  Text(AppLocalizations.of(context)!.youBlockedThisUser)
                ] else ...[
                  Text(
                    discussion.lastMessage != null
                        ? discussion.lastMessage!.content
                        : "",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
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
