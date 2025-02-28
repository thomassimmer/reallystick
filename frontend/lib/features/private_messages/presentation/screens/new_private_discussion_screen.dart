import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_creation/private_message_creation_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_creation/private_message_creation_events.dart';
import 'package:reallystick/features/private_messages/presentation/widgets/custom_message_input.dart';
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

  void _sendMessage() {
    final userState = context.read<UserBloc>().state;
    final profileState = context.read<ProfileBloc>().state;

    if (userState is UsersLoaded && profileState is ProfileAuthenticated) {
      final recipient = userState.users[widget.recipientId]!;
      final recipientPublicKey = recipient.publicKey!;
      final creatorPublicKey = profileState.profile.publicKey!;

      final privateMessageCreationFormBloc =
          context.read<PrivateMessageCreationFormBloc>();

      privateMessageCreationFormBloc.add(
        PrivateMessageCreationFormContentChangedEvent(_contentController.text),
      );

      Future.delayed(const Duration(milliseconds: 50), () {
        if (privateMessageCreationFormBloc.state.isValid) {
          final newDiscussionEvent = AddNewDiscussionEvent(
            recipient: widget.recipientId,
            content: _contentController.text,
            creatorPublicKey: creatorPublicKey,
            recipientPublicKey: recipientPublicKey,
          );

          if (mounted) {
            context.read<PrivateDiscussionBloc>().add(newDiscussionEvent);
          }

          setState(() {
            _contentController.text = '';
          });
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userState = context.watch<UserBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;
    final privateDiscussionState = context.watch<PrivateDiscussionBloc>().state;

    if (userState is UsersLoaded && profileState is ProfileAuthenticated) {
      final recipient = userState.users[widget.recipientId];

      if (recipient == null) {
        BlocProvider.of<UserBloc>(context).add(
          GetUserPublicDataEvent(
            userIds: [widget.recipientId],
            username: null,
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
              context: context,
              message: ErrorMessage("recipientMissingPublicKey"),
            );
            context.pop();
          },
        );
      }

      if (creatorPublicKey == null) {
        Future.microtask(
          () {
            GlobalSnackBar.show(
              context: context,
              message: ErrorMessage("creatorMissingPublicKey"),
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

    if (userState is UsersLoaded) {
      final recipient = userState.users[widget.recipientId]!;

      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            AppLocalizations.of(context)!.newDiscussion,
            textAlign: TextAlign.left,
            style: context.typographies.headingSmall,
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
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              CustomMessageInput(
                contentController: _contentController,
                recipientUsername: recipient.username,
                onSendMessage: _sendMessage,
              )
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
