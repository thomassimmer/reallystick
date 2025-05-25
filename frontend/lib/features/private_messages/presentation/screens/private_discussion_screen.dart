import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_list_view.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/habits/presentation/screens/color_picker_modal.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_creation/private_message_creation_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_creation/private_message_creation_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_update/private_message_update_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_update/private_message_update_events.dart';
import 'package:reallystick/features/private_messages/presentation/widgets/custom_message_input.dart';
import 'package:reallystick/features/private_messages/presentation/widgets/private_message_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class PrivateDiscussionScreen extends StatefulWidget {
  final String discussionId;
  final bool previewMode;

  const PrivateDiscussionScreen({
    super.key,
    required this.discussionId,
    required this.previewMode,
  });

  @override
  PrivateDiscussionScreenState createState() => PrivateDiscussionScreenState();
}

class PrivateDiscussionScreenState extends State<PrivateDiscussionScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  PrivateMessage? _messageBeingEdited;
  bool _isFetchingOlderMessages = false;
  bool noMoreMessagesToFetch = false;

  @override
  void initState() {
    super.initState();

    _contentController.addListener(() {
      setState(() {});
    });

    final privateMessageState = context.read<PrivateMessageBloc>().state;

    if (privateMessageState.discussionId != widget.discussionId) {
      BlocProvider.of<PrivateMessageBloc>(context).add(
        InitializePrivateMessagesEvent(
          discussionId: widget.discussionId,
        ),
      );
    }

    scrollController.addListener(() async {
      if (scrollController.offset ==
              scrollController.position.maxScrollExtent &&
          !_isFetchingOlderMessages &&
          !noMoreMessagesToFetch) {
        setState(() {
          _isFetchingOlderMessages = true;
        });

        if (mounted) {
          final privateMessageState = context.read<PrivateMessageBloc>().state;
          final messages = privateMessageState
              .messagesByDiscussion[widget.discussionId]?.values
              .toList();

          if (messages != null && messages.isNotEmpty) {
            messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            final oldestMessage = messages.first;

            _pullOlderMessages(oldestMessage);
          }
        }
      }
    });

    final userState = context.read<UserBloc>().state;
    final profileState = context.read<ProfileBloc>().state;
    final privateDiscussionState = context.read<PrivateDiscussionBloc>().state;

    if (userState is UsersLoaded && profileState is ProfileAuthenticated) {
      final existingDiscussion =
          privateDiscussionState.discussions[widget.discussionId];

      if (existingDiscussion == null) {
        return;
      }

      final recipient = userState.users[existingDiscussion.recipientId];

      if (recipient == null) {
        BlocProvider.of<UserBloc>(context).add(
          GetUserPublicDataEvent(
            userIds: [existingDiscussion.recipientId],
            username: null,
          ),
        );
        return; // Prevent further execution.
      }

      final recipientPublicKey = recipient.publicKey;
      final creatorPublicKey = profileState.profile.publicKey;

      if (recipientPublicKey == null) {
        Future.microtask(
          () {
            if (mounted) {
              GlobalSnackBar.show(
                context: context,
                message: ErrorMessage("recipientMissingPublicKey"),
              );
              context.pop();
            }
          },
        );
      }

      if (creatorPublicKey == null) {
        Future.microtask(
          () {
            if (mounted) {
              GlobalSnackBar.show(
                context: context,
                message: ErrorMessage("creatorMissingPublicKey"),
              );
              context.pop();
            }
          },
        );
      }
    }
  }

  Future<void> _pullOlderMessages(PrivateMessage? oldestMessage) async {
    final completer = Completer<int>();
    context.read<PrivateMessageBloc>().add(
          FetchOlderMessagesEvent(
            discussionId: widget.discussionId,
            beforeDate: oldestMessage?.createdAt,
            completer: completer,
          ),
        );

    final newlyInsertedMessageCount = await completer.future;

    setState(() {
      _isFetchingOlderMessages = false;
    });

    if (newlyInsertedMessageCount == 0) {
      noMoreMessagesToFetch = true;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();

    super.dispose();
  }

  void _sendMessage(String? recipientPublicKey, String? creatorPublicKey) {
    final privateMessageCreationFormBloc =
        context.read<PrivateMessageCreationFormBloc>();

    privateMessageCreationFormBloc.add(
      PrivateMessageCreationFormContentChangedEvent(_contentController.text),
    );

    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (privateMessageCreationFormBloc.state.isValid) {
          final newMessageEvent = AddNewMessageEvent(
            discussionId: widget.discussionId,
            content: _contentController.text,
            creatorPublicKey: creatorPublicKey!,
            recipientPublicKey: recipientPublicKey!,
          );

          if (mounted) {
            context.read<PrivateMessageBloc>().add(newMessageEvent);
          }

          setState(() {
            _contentController.text = "";
            _messageBeingEdited = null;
          });
        }
      },
    );
  }

  void _editMessage() {
    final privateMessageUpdateFormBloc =
        context.read<PrivateMessageUpdateFormBloc>();

    privateMessageUpdateFormBloc.add(
      PrivateMessageUpdateFormContentChangedEvent(_contentController.text),
    );

    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (privateMessageUpdateFormBloc.state.isValid) {
          // If editing, trigger update event
          final updateMessageEvent = UpdateMessageEvent(
            discussionId: widget.discussionId,
            creatorEncryptedSessionKey:
                _messageBeingEdited!.creatorEncryptedSessionKey,
            messageId: _messageBeingEdited!.id,
            content: _contentController.text,
          );

          if (mounted) {
            context.read<PrivateMessageBloc>().add(updateMessageEvent);
          }

          setState(() {
            _contentController.text = "";
            _messageBeingEdited = null;
          });
        }
      },
    );
  }

  void _deleteMessage(String messageId) {
    context.read<PrivateMessageBloc>().add(
          DeleteMessageEvent(
            discussionId: widget.discussionId,
            messageId: messageId,
          ),
        );
  }

  void _openColorPicker(PrivateDiscussion discussion) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
      builder: (BuildContext context) {
        return ColorPickerModal(
          onColorSelected: (selectedColor) {
            final updateDiscussionParticipationEvent =
                UpdateDiscussionParticipationEvent(
                    discussionId: widget.discussionId,
                    color: selectedColor.toShortString(),
                    hasBlocked: discussion.hasBlocked);
            context
                .read<PrivateDiscussionBloc>()
                .add(updateDiscussionParticipationEvent);

            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _blockUser(PrivateDiscussion discussion) async {
    final updateDiscussionParticipationEvent =
        UpdateDiscussionParticipationEvent(
            discussionId: widget.discussionId,
            color: discussion.color,
            hasBlocked: !discussion.hasBlocked);
    context
        .read<PrivateDiscussionBloc>()
        .add(updateDiscussionParticipationEvent);
  }

  @override
  Widget build(BuildContext context) {
    final profileState = widget.previewMode
        ? getProfileAuthenticatedForPreview(context)
        : context.watch<ProfileBloc>().state;
    final userState = widget.previewMode
        ? getUserStateForPreview(context)
        : context.watch<UserBloc>().state;
    final privateMessageState = widget.previewMode
        ? getPrivateMessageStateForPreview(context)
        : context.watch<PrivateMessageBloc>().state;
    final privateDiscussionState = widget.previewMode
        ? getPrivateDiscussionStateForPreview(context)
        : context.watch<PrivateDiscussionBloc>().state;

    if (userState is UsersLoaded && profileState is ProfileAuthenticated) {
      if (privateMessageState.discussionId != widget.discussionId) {
        return buildLoadingScreen();
      }

      if (privateDiscussionState.discussions[widget.discussionId] == null) {
        return buildLoadingScreen();
      }

      final userLocale = profileState.profile.locale;
      final discussion =
          privateDiscussionState.discussions[widget.discussionId]!;

      final recipient = userState.users[discussion.recipientId]!;
      List<PrivateMessage> messages = privateMessageState
              .messagesByDiscussion[widget.discussionId]?.values
              .toList() ??
          [];

      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return Scaffold(
        appBar: CustomAppBar(
          title: Text(
            recipient.isDeleted
                ? AppLocalizations.of(context)!.deletedUser
                : recipient.username,
            style: context.typographies.headingSmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          actions: [
            PopupMenuButton<String>(
              color: context.colors.backgroundDark,
              onSelected: (value) async {
                if (value == 'block') {
                  _blockUser(discussion);
                } else if (value == 'change_color') {
                  _openColorPicker(discussion);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'block',
                  child: Text(discussion.hasBlocked
                      ? AppLocalizations.of(context)!.unblockThisUser
                      : AppLocalizations.of(context)!.blockThisUser),
                ),
                PopupMenuItem(
                  value: 'change_color',
                  child: Text(AppLocalizations.of(context)!.changeColor),
                ),
              ],
            ),
          ],
        ),
        body: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 700,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (discussion.hasBlocked) ...[
                  Text(AppLocalizations.of(context)!.youBlockedThisUser)
                ] else ...[
                  Expanded(
                    child: FullWidthListView(
                      controller: scrollController,
                      reverse: true,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.yellow, width: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .messagesAreEncrypted,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_isFetchingOlderMessages)
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        SizedBox(height: 20),
                        ...List.generate(
                          messages.length,
                          (index) {
                            final message = messages[index];

                            return Column(
                              children: [
                                if (index > 0 &&
                                    messages[index - 1]
                                            .createdAt
                                            .day
                                            .compareTo(message.createdAt.day) <
                                        0) ...[
                                  Text(
                                    DateFormat.yMEd(userLocale)
                                        .format(message.createdAt),
                                    style: TextStyle(
                                      color: context.colors.hint,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                                GestureDetector(
                                  onLongPressStart: (details) async {
                                    final offset = details.globalPosition;
                                    final userIsCreator = message.creator ==
                                        profileState.profile.id;

                                    if (userIsCreator) {
                                      showMenu(
                                        context: context,
                                        position: RelativeRect.fromLTRB(
                                          offset.dx,
                                          offset.dy,
                                          MediaQuery.of(context).size.width -
                                              offset.dx,
                                          MediaQuery.of(context).size.height -
                                              offset.dy,
                                        ),
                                        items: [
                                          PopupMenuItem(
                                            value: 'update',
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .edit),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .delete),
                                          ),
                                        ],
                                      ).then(
                                        (value) {
                                          if (value == 'update') {
                                            setState(() {
                                              _contentController.text =
                                                  message.content;
                                              _messageBeingEdited = message;
                                            });
                                          } else if (value == 'delete') {
                                            _deleteMessage(message.id);
                                          }
                                        },
                                      );
                                    }
                                  },
                                  child: PrivateMessageWidget(
                                    key: ValueKey(message.id),
                                    discussionId: widget.discussionId,
                                    message: message,
                                    color: AppColorExtension.fromString(
                                            discussion.color)
                                        .color,
                                    userId: profileState.profile.id,
                                    previewMode: widget.previewMode,
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (!recipient.isDeleted)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: CustomMessageInput(
                        contentController: _contentController,
                        recipientUsername: recipient.username,
                        onSendMessage: () => _sendMessage(
                          recipient.publicKey,
                          profileState.profile.publicKey,
                        ),
                        isEditing: _messageBeingEdited != null,
                        onEditMessage: _editMessage,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      );
    } else {
      return buildLoadingScreen();
    }
  }

  Widget buildLoadingScreen() {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Container(
            constraints: BoxConstraints(
              maxWidth: 700,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.yourMessagesAreLoading)
              ],
            )),
      ),
    );
  }
}
