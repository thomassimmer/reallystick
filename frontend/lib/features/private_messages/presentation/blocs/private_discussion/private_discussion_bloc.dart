import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/auth/data/storage/private_message_key_storage.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';
import 'package:reallystick/features/private_messages/domain/usecases/create_private_discussion_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/decrypt_message_using_aes_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/decrypt_symmetric_key_with_rsa_private_key_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/get_private_discussions.dart';
import 'package:reallystick/features/private_messages/domain/usecases/mark_private_message_as_seen_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/update_private_discussion_participation_usecase.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_states.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';

class PrivateDiscussionBloc
    extends Bloc<PrivateDiscussionEvent, PrivateDiscussionState> {
  final AuthBloc authBloc = GetIt.instance<AuthBloc>();
  final UserBloc userBloc = GetIt.instance<UserBloc>();
  final ProfileBloc profileBloc = GetIt.instance<ProfileBloc>();
  final PrivateMessageBloc privateMessageBloc =
      GetIt.instance<PrivateMessageBloc>();
  final NotificationBloc notificationBloc = GetIt.instance<NotificationBloc>();

  late StreamSubscription profileBlocSubscription;
  late StreamSubscription privateMessageBlocSubscription;

  final GetPrivateDiscussionsUsecase getPrivateDiscussionsUsecase =
      GetIt.instance<GetPrivateDiscussionsUsecase>();
  final CreatePrivateDiscussionUsecase createPrivateDiscussionUsecase =
      GetIt.instance<CreatePrivateDiscussionUsecase>();
  final UpdatePrivateDiscussionParticipationUsecase
      updatePrivateDiscussionParticipationUsecase =
      GetIt.instance<UpdatePrivateDiscussionParticipationUsecase>();
  final DecryptSymmetricKeyWithRsaPrivateKeyUsecase
      decryptSymmetricKeyWithRsaPrivateKeyUsecase =
      GetIt.instance<DecryptSymmetricKeyWithRsaPrivateKeyUsecase>();
  final DecryptMessageUsingAesUsecase decryptMessageUsingAesUsecase =
      GetIt.instance<DecryptMessageUsingAesUsecase>();
  final MarkPrivateMessageAsSeenUsecase markPrivateMessageAsSeenUsecase =
      GetIt.instance<MarkPrivateMessageAsSeenUsecase>();

  String? userId;

  PrivateDiscussionBloc() : super(PrivateDiscussionState(discussions: {})) {
    profileBlocSubscription = profileBloc.stream.listen(
      (profileState) {
        if (profileState is ProfileAuthenticated) {
          userId = profileState.profile.id;
          add(InitializePrivateDiscussionsEvent());
        }
      },
    );

    privateMessageBlocSubscription = privateMessageBloc.stream.listen(
      (privateMessageState) {
        if (privateMessageState.lastPrivateMessageReceivedEvent != null) {
          if (privateMessageState.lastPrivateMessageReceivedEvent!.type ==
              "private_message_created") {
            add(
              MessageCreatedReceivedEvent(
                message: privateMessageState
                    .lastPrivateMessageReceivedEvent!.message,
              ),
            );
          } else if (privateMessageState
                  .lastPrivateMessageReceivedEvent!.type ==
              "private_message_updated") {
            add(
              MessageUpdatedReceivedEvent(
                message: privateMessageState
                    .lastPrivateMessageReceivedEvent!.message,
              ),
            );
          } else if (privateMessageState
                  .lastPrivateMessageReceivedEvent!.type ==
              "private_message_deleted") {
            add(
              MessageDeletedReceivedEvent(
                message: privateMessageState
                    .lastPrivateMessageReceivedEvent!.message,
              ),
            );
          } else if (privateMessageState
                  .lastPrivateMessageReceivedEvent!.type ==
              "private_message_marked_as_seen") {
            add(
              MessageMarkedAsSeenReceivedEvent(
                message: privateMessageState
                    .lastPrivateMessageReceivedEvent!.message,
              ),
            );
          }
        }
      },
    );

    on<InitializePrivateDiscussionsEvent>(initialize);
    on<AddNewDiscussionEvent>(onAddNewDiscussion);
    on<UpdateDiscussionParticipationEvent>(onUpdateDiscussion);
    on<MessageCreatedReceivedEvent>(
      onMessageCreatedReceived,
      transformer: sequential(),
    );
    on<MessageUpdatedReceivedEvent>(
      onMessageUpdatedReceived,
      transformer: sequential(),
    );
    on<MessageDeletedReceivedEvent>(
      onMessageDeletedReceived,
      transformer: sequential(),
    );
    on<MessageMarkedAsSeenReceivedEvent>(
      onMessageMarkedAsSeenReceived,
      transformer: sequential(),
    );
    on<MarkPrivateMessageAsSeenInDiscussionEvent>(
      onMarkMessageAsSeen,
      transformer: sequential(),
    );
  }

  Future<void> initialize(
    InitializePrivateDiscussionsEvent event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state;

    final result = await getPrivateDiscussionsUsecase.call();

    await result.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PrivateDiscussionState(
              discussions: currentState.discussions,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (discussions) async {
        Set<String> usersToGetInfoFor = <String>{};

        // Decrypt last messages of discussions to show a preview in DiscussionWidget
        for (final discussion in discussions) {
          if (discussion.lastMessage == null) {
            continue;
          }

          usersToGetInfoFor.add(discussion.lastMessage!.creator);
          usersToGetInfoFor.add(discussion.recipientId);

          final isCreator = discussion.lastMessage!.creator == userId;
          final privateKey = await PrivateMessageKeyStorage().getPrivateKey();

          String clearContent =
              "Failed to find private key. Can't decrypt this message";

          if (privateKey != null) {
            final aesKey =
                await decryptSymmetricKeyWithRsaPrivateKeyUsecase.call(
              encryptedAesKey: isCreator
                  ? discussion.lastMessage!.creatorEncryptedSessionKey
                  : discussion.lastMessage!.recipientEncryptedSessionKey,
              rsaPrivateKeyPem: privateKey,
            );
            clearContent = await decryptMessageUsingAesUsecase.call(
                encryptedContent: discussion.lastMessage!.content,
                aesKey: aesKey);
          }

          discussion.lastMessage!.content = clearContent;
        }

        // Check if we are missing some user info
        userBloc.add(
          GetUserPublicDataEvent(
            userIds: usersToGetInfoFor.toList(),
          ),
        );

        emit(
          PrivateDiscussionState(
            discussions: Map.fromEntries(
              discussions.map(
                (d) => MapEntry(d.id, d),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> onAddNewDiscussion(
    AddNewDiscussionEvent event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state;
    final result = await createPrivateDiscussionUsecase.call(
      recipientId: event.recipient,
      color: AppColorExtension.getRandomColor().toShortString(),
    );

    result.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PrivateDiscussionState(
              discussions: currentState.discussions,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (newDiscussion) {
        currentState.discussions[newDiscussion.id] = newDiscussion;

        privateMessageBloc.add(
          AddNewMessageEvent(
            discussionId: newDiscussion.id,
            content: event.content,
            creatorPublicKey: event.creatorPublicKey,
            recipientPublicKey: event.recipientPublicKey,
          ),
        );

        emit(
          PrivateDiscussionState(
            discussions: currentState.discussions,
          ),
        );
      },
    );
  }

  Future<void> onUpdateDiscussion(
    UpdateDiscussionParticipationEvent event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state;
    final result = await updatePrivateDiscussionParticipationUsecase.call(
      discussionId: event.discussionId,
      hasBlocked: event.hasBlocked,
      color: event.color,
    );

    result.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PrivateDiscussionState(
              discussions: currentState.discussions,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        if (currentState.discussions.containsKey(event.discussionId)) {
          final newDiscussion =
              currentState.discussions[event.discussionId]!.copyWith(
            color: event.color,
            hasBlocked: event.hasBlocked,
          );

          final newDiscussions =
              Map<String, PrivateDiscussion>.from(currentState.discussions)
                ..[event.discussionId] = newDiscussion;

          emit(
            PrivateDiscussionState(
              discussions: newDiscussions,
            ),
          );
        }
      },
    );
  }

  Future<void> onMessageCreatedReceived(
    MessageCreatedReceivedEvent event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state;

    if (currentState.discussions.containsKey(event.message.discussionId)) {
      final oldDiscussion =
          currentState.discussions[event.message.discussionId]!;

      final userId = profileBloc.state.profile!.id;

      final updatedDiscussion = oldDiscussion.copyWith(
        lastMessage: event.message,
        unseenMessages: userId != event.message.creator
            ? oldDiscussion.unseenMessages + 1
            : oldDiscussion.unseenMessages,
      );

      final updatedDiscussions =
          Map<String, PrivateDiscussion>.from(currentState.discussions)
            ..[event.message.discussionId] = updatedDiscussion;

      emit(PrivateDiscussionState(
        discussions: updatedDiscussions,
      ));
    } else {
      final result = await getPrivateDiscussionsUsecase.call();

      await result.fold(
        (error) {
          if (error is ShouldLogoutError) {
            authBloc.add(
              AuthLogoutEvent(
                message: ErrorMessage(error.messageKey),
              ),
            );
          } else {
            emit(
              PrivateDiscussionState(
                discussions: currentState.discussions,
                message: ErrorMessage(error.messageKey),
              ),
            );
          }
        },
        (discussions) async {
          PrivateDiscussion? newDiscussion = discussions
              .where((d) => d.id == event.message.discussionId)
              .firstOrNull;

          Set<String> usersToGetInfoFor = <String>{};

          if (newDiscussion != null) {
            currentState.discussions[newDiscussion.id] = newDiscussion;
            usersToGetInfoFor.add(newDiscussion.recipientId);
          }

          // Check if we are missing some user info
          userBloc.add(
            GetUserPublicDataEvent(
              userIds: usersToGetInfoFor.toList(),
            ),
          );

          emit(
            PrivateDiscussionState(
              discussions: currentState.discussions,
            ),
          );
        },
      );
    }
  }

  Future<void> onMessageUpdatedReceived(
    MessageUpdatedReceivedEvent event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state;

    if (currentState.discussions.containsKey(event.message.discussionId)) {
      final oldDiscussion =
          currentState.discussions[event.message.discussionId]!;

      // If we will not update the last message, return now.
      if (oldDiscussion.lastMessage != null) {
        if (oldDiscussion.lastMessage!.id != event.message.id) {
          return;
        }
      }

      final updatedDiscussion = oldDiscussion.copyWith(
        lastMessage: event.message,
      );

      final updatedDiscussions =
          Map<String, PrivateDiscussion>.from(currentState.discussions)
            ..[event.message.discussionId] = updatedDiscussion;

      emit(PrivateDiscussionState(
        discussions: updatedDiscussions,
      ));
    }
  }

  Future<void> onMessageDeletedReceived(
    MessageDeletedReceivedEvent event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state;

    if (currentState.discussions.containsKey(event.message.discussionId)) {
      final oldDiscussion =
          currentState.discussions[event.message.discussionId]!;

      // If we will not update the last message, return now.
      if (oldDiscussion.lastMessage != null) {
        if (oldDiscussion.lastMessage!.id != event.message.id) {
          return;
        }
      }

      final updatedDiscussion = oldDiscussion.copyWith(
        lastMessage: event.message,
      );

      final updatedDiscussions =
          Map<String, PrivateDiscussion>.from(currentState.discussions)
            ..[event.message.discussionId] = updatedDiscussion;

      emit(PrivateDiscussionState(
        discussions: updatedDiscussions,
      ));
    }
  }

  Future<void> onMessageMarkedAsSeenReceived(
    MessageMarkedAsSeenReceivedEvent event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state;

    if (currentState.discussions.containsKey(event.message.discussionId)) {
      final oldDiscussion =
          currentState.discussions[event.message.discussionId]!;

      final userId = profileBloc.state.profile!.id;

      final updatedDiscussion = oldDiscussion.copyWith(
        unseenMessages: userId != event.message.creator
            ? oldDiscussion.unseenMessages - 1
            : oldDiscussion.unseenMessages,
      );

      final updatedDiscussions =
          Map<String, PrivateDiscussion>.from(currentState.discussions)
            ..[event.message.discussionId] = updatedDiscussion;

      emit(PrivateDiscussionState(
        discussions: updatedDiscussions,
      ));
    }
  }

  Future<void> onMarkMessageAsSeen(
    MarkPrivateMessageAsSeenInDiscussionEvent event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state;

    final result = await markPrivateMessageAsSeenUsecase.call(
      privateMessageId: event.message.id,
    );

    result.fold((error) {
      if (error is ShouldLogoutError) {
        authBloc.add(
          AuthLogoutEvent(
            message: ErrorMessage(error.messageKey),
          ),
        );
      } else {
        emit(
          PrivateDiscussionState(
            discussions: currentState.discussions,
            message: ErrorMessage(error.messageKey),
          ),
        );
      }
    }, (_) {});

    // Don't do anything here, we will receive a message on the websocket and
    // update the state at this moment.
  }
}
