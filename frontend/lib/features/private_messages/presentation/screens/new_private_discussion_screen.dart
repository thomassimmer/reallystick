import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_states.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_creation/private_message_creation_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_creation/private_message_creation_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

class NewPrivateDiscussionScreen extends StatefulWidget {
  final String recipientId;

  const NewPrivateDiscussionScreen({
    Key? key,
    required this.recipientId,
  }) : super(key: key);

  @override
  NewPrivateDiscussionScreenState createState() =>
      NewPrivateDiscussionScreenState();
}

class NewPrivateDiscussionScreenState
    extends State<NewPrivateDiscussionScreen> {
  String _content = "";

  void _sendMessage({
    required String creatorPublicKey,
    required String recipientPublicKey,
  }) {
    final privateMessageCreationFormBloc =
        context.read<PrivateMessageCreationFormBloc>();

    privateMessageCreationFormBloc.add(
      PrivateMessageCreationFormContentChangedEvent(_content),
    );

    Future.delayed(const Duration(milliseconds: 50), () {
      if (privateMessageCreationFormBloc.state.isValid) {
        final newDiscussionEvent = AddNewDiscussionEvent(
          recipient: widget.recipientId,
          content: _content,
          creatorPublicKey: creatorPublicKey,
          recipientPublicKey: recipientPublicKey,
        );

        if (mounted) {
          context.read<PrivateDiscussionBloc>().add(newDiscussionEvent);
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userState = context.watch<UserBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;
    final privateDiscussionState = context.watch<PrivateDiscussionBloc>().state;

    if (userState is UsersLoaded &&
        privateDiscussionState is PrivateDiscussionLoaded &&
        profileState is ProfileAuthenticated) {
      final recipient = userState.users[widget.recipientId];

      if (recipient == null) {
        BlocProvider.of<UserBloc>(context).add(
          GetUserPublicDataEvent(
            userIds: [widget.recipientId],
          ),
        );
        return; // Prevent further execution.
      }

      final existingDiscussion = privateDiscussionState.discussions.values
          .where((d) => d.recipientId == widget.recipientId)
          .firstOrNull;

      if (existingDiscussion != null) {
        Future.microtask(
          () => context.goNamed(
            'discussion',
            pathParameters: {'discussionId': existingDiscussion.id},
          ),
        );
        return;
      }

      final recipientPublicKey = recipient.publicKey;
      final creatorPublicKey = profileState.profile.publicKey;

      if (recipientPublicKey == null) {
        Future.microtask(
          () {
            GlobalSnackBar.show(
              context,
              ErrorMessage("recipientMissingPublicKey"),
            );
            context.pop();
          },
        );
      }

      if (creatorPublicKey == null) {
        Future.microtask(
          () {
            GlobalSnackBar.show(
              context,
              ErrorMessage("creatorMissingPublicKey"),
            );
            context.pop();
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;
    final privateDiscussionState = context.watch<PrivateDiscussionBloc>().state;

    if (userState is UsersLoaded &&
        privateDiscussionState is PrivateDiscussionLoaded &&
        profileState is ProfileAuthenticated) {
      final recipient = userState.users[widget.recipientId]!;
      final recipientPublicKey = recipient.publicKey;
      final creatorPublicKey = profileState.profile.publicKey;

      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            AppLocalizations.of(context)!.newDiscussion,
            textAlign: TextAlign.left,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.noMessagesYet,
                  ),
                ),
              ),
              TextField(
                onSubmitted: (_) => _sendMessage(
                  creatorPublicKey: creatorPublicKey!,
                  recipientPublicKey: recipientPublicKey!,
                ),
                onChanged: (value) => {
                  setState(() {
                    _content = value;
                  })
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.replyTo(
                    recipient.username,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _content.trim().isNotEmpty
                          ? context.colors.primary
                          : context.colors.hint,
                    ),
                    onPressed: _content.trim().isNotEmpty
                        ? () {
                            _sendMessage(
                              creatorPublicKey: creatorPublicKey!,
                              recipientPublicKey: recipientPublicKey!,
                            );
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
