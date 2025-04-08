import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_events.dart';
import 'package:reallystick/features/private_messages/presentation/widgets/status_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

class PrivateMessageWidget extends StatefulWidget {
  final String discussionId;
  final PrivateMessage message;
  final Color color;
  final String userId;

  const PrivateMessageWidget({
    required this.discussionId,
    required this.message,
    required this.color,
    required this.userId,
  });

  @override
  PrivateMessageWidgetState createState() => PrivateMessageWidgetState();
}

class PrivateMessageWidgetState extends State<PrivateMessageWidget> {
  void markMessageAsSeen() {
    BlocProvider.of<PrivateDiscussionBloc>(context).add(
      MarkPrivateMessageAsSeenInDiscussionEvent(
        message: widget.message,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!widget.message.seen && widget.message.creator != widget.userId) {
      markMessageAsSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;

    if (userState is UsersLoaded && profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;
      final userIsCreator = widget.message.creator == profileState.profile.id;

      return Align(
        alignment: userIsCreator ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            left: userIsCreator ? 80 : 0,
            right: userIsCreator ? 0 : 80,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: widget.color.withAlpha(100)),
            boxShadow: [
              BoxShadow(
                color: userIsCreator
                    ? widget.color.withValues(alpha: 0.3)
                    : widget.color.withValues(alpha: 0.1),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: userIsCreator
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.deleted
                      ? AppLocalizations.of(context)!.messageDeletedError
                      : widget.message.content.replaceAll('\\n', '\n'),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.message.updateAt == null
                          ? DateFormat.Hm().format(widget.message.createdAt)
                          : AppLocalizations.of(context)!.editedAt(
                              DateFormat.yMEd(userLocale)
                                  .add_Hm()
                                  .format(widget.message.updateAt!),
                            ),
                      style: TextStyle(
                        color: context.colors.hint,
                        fontSize: 12,
                      ),
                    ),
                    if (userIsCreator) StatusWidget(isSeen: widget.message.seen)
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
