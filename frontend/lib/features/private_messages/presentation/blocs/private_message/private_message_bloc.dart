import 'dart:async';
import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/auth/data/storage/private_message_key_storage.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';
import 'package:reallystick/features/private_messages/domain/usecases/create_private_message_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/decrypt_message_using_aes_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/decrypt_symmetric_key_with_rsa_private_key_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/delete_private_message_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/encrypt_message_using_aes_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/encrypt_symmetric_key_with_rsa_public_key_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/get_private_messages_of_discussion_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/update_private_message_usecase.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_states.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';

class PrivateMessageBloc extends Bloc<PrivateMessageEvent, PrivateMessageState>
    with WidgetsBindingObserver {
  final AuthBloc authBloc = GetIt.instance<AuthBloc>();
  final UserBloc userBloc = GetIt.instance<UserBloc>();
  final ProfileBloc profileBloc = GetIt.instance<ProfileBloc>();

  late StreamSubscription profileBlocSubscription;

  final GetPrivateMessagesOfDiscussionUsecase
      getPrivateMessagesOfDiscussionUsecase =
      GetIt.instance<GetPrivateMessagesOfDiscussionUsecase>();
  final CreatePrivateMessageUsecase createPrivateMessageUsecase =
      GetIt.instance<CreatePrivateMessageUsecase>();
  final EncryptMessageUsingAesUsecase encryptMessageUsingAesUsecase =
      GetIt.instance<EncryptMessageUsingAesUsecase>();
  final EncryptSymmetricKeyWithRsaPublicKeyUsecase
      encryptSymmetricKeyWithRsaPublicKeyUsecase =
      GetIt.instance<EncryptSymmetricKeyWithRsaPublicKeyUsecase>();
  final DecryptSymmetricKeyWithRsaPrivateKeyUsecase
      decryptSymmetricKeyWithRsaPrivateKeyUsecase =
      GetIt.instance<DecryptSymmetricKeyWithRsaPrivateKeyUsecase>();
  final DecryptMessageUsingAesUsecase decryptMessageUsingAesUsecase =
      GetIt.instance<DecryptMessageUsingAesUsecase>();
  final DeletePrivateMessageUsecase deletePrivateMessageUsecase =
      GetIt.instance<DeletePrivateMessageUsecase>();

  final UpdatePrivateMessageUsecase updatePrivateMessageUsecase =
      GetIt.instance<UpdatePrivateMessageUsecase>();

  String? userId;

  PrivateMessageBloc()
      : super(PrivateMessageState(
          discussionId: null,
          messagesByDiscussion: {},
          lastPrivateMessageReceivedEvent: null,
        )) {
    profileBlocSubscription = profileBloc.stream.listen((profileState) {
      if (profileState is ProfileAuthenticated) {
        userId = profileState.profile.id;
      }
    });

    on<InitializePrivateMessagesEvent>(initialize);
    on<PrivateMessageReceivedEvent>(
      onMessageReceived,
      transformer: sequential(),
    );
    on<AddNewMessageEvent>(onAddNewMessage);
    on<UpdateMessageEvent>(onUpdateMessage);
    on<DeleteMessageEvent>(onDeleteMessage);
    on<FetchOlderMessagesEvent>(onFetchOlderMessages);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (this.state.discussionId != null) {
        add(
          InitializePrivateMessagesEvent(
            discussionId: this.state.discussionId!,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }

  Future<void> initialize(
    InitializePrivateMessagesEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    final currentState = state;

    final result = await getPrivateMessagesOfDiscussionUsecase.call(
      discussionId: event.discussionId,
      beforeDate: null,
    );

    List<PrivateMessage> messages = await result.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PrivateMessageState(
              discussionId: currentState.discussionId,
              messagesByDiscussion: currentState.messagesByDiscussion,
              lastPrivateMessageReceivedEvent: null,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
        return [];
      },
      (newMessages) async {
        final privateKey = await PrivateMessageKeyStorage().getPrivateKey();

        for (final message in newMessages) {
          final isCreator = message.creator == userId;

          String clearContent =
              "Failed to find private key. Can't decrypt this message";

          if (message.creatorEncryptedSessionKey == 'NOT_ENCRYPTED' ||
              message.content.isEmpty) {
            clearContent = message.content;
          } else if (privateKey != null) {
            try {
              final aesKey =
                  await decryptSymmetricKeyWithRsaPrivateKeyUsecase.call(
                encryptedAesKey: isCreator
                    ? message.creatorEncryptedSessionKey
                    : message.recipientEncryptedSessionKey,
                rsaPrivateKeyPem: privateKey,
              );

              clearContent = await decryptMessageUsingAesUsecase.call(
                encryptedContent: message.content,
                aesKey: aesKey,
              );
            } catch (_) {
              clearContent = "An error occured while decrypting this messsage";
            }
          }

          message.content = clearContent;
        }

        return newMessages;
      },
    );

    // Check if we are missing some user info
    userBloc.add(
      GetUserPublicDataEvent(
        userIds: messages.map((m) => m.creator).toList(),
        username: null,
      ),
    );

    currentState.messagesByDiscussion[event.discussionId] = Map.fromEntries(
      messages.map(
        (m) => MapEntry(m.id, m),
      ),
    );

    emit(
      PrivateMessageState(
        discussionId: event.discussionId,
        messagesByDiscussion: currentState.messagesByDiscussion,
        lastPrivateMessageReceivedEvent: null,
      ),
    );
  }

  Future<void> onFetchOlderMessages(
    FetchOlderMessagesEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    final currentState = state;

    final result = await getPrivateMessagesOfDiscussionUsecase.call(
      discussionId: event.discussionId,
      beforeDate: event.beforeDate,
    );

    List<PrivateMessage> olderMessages = await result.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PrivateMessageState(
              discussionId: currentState.discussionId,
              messagesByDiscussion: currentState.messagesByDiscussion,
              lastPrivateMessageReceivedEvent: null,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
        return [];
      },
      (messages) async {
        final privateKey = await PrivateMessageKeyStorage().getPrivateKey();

        for (final message in messages) {
          final isCreator = message.creator == userId;

          String clearContent =
              "Failed to find private key. Can't decrypt this message";

          if (message.creatorEncryptedSessionKey == 'NOT_ENCRYPTED' ||
              message.content.isEmpty) {
            clearContent = message.content;
          } else if (privateKey != null) {
            final aesKey =
                await decryptSymmetricKeyWithRsaPrivateKeyUsecase.call(
              encryptedAesKey: isCreator
                  ? message.creatorEncryptedSessionKey
                  : message.recipientEncryptedSessionKey,
              rsaPrivateKeyPem: privateKey,
            );

            clearContent = await decryptMessageUsingAesUsecase.call(
              encryptedContent: message.content,
              aesKey: aesKey,
            );
          }

          message.content = clearContent;
        }

        return messages;
      },
    );

    // Check if we are missing some user info
    userBloc.add(
      GetUserPublicDataEvent(
        userIds: olderMessages.map((m) => m.creator).toList(),
        username: null,
      ),
    );

    final existingMessagesMap = Map<String, PrivateMessage>.from(
      currentState.messagesByDiscussion[event.discussionId] ?? {},
    );

    for (final message in olderMessages) {
      existingMessagesMap[message.id] = message;
    }

    final updatedMessagesByDiscussion =
        Map<String, Map<String, PrivateMessage>>.from(
            currentState.messagesByDiscussion)
          ..[event.discussionId] = existingMessagesMap;

    emit(
      PrivateMessageState(
        discussionId: event.discussionId,
        messagesByDiscussion: updatedMessagesByDiscussion,
        lastPrivateMessageReceivedEvent: null,
      ),
    );

    event.completer?.complete(olderMessages.length);
  }

  Future<void> onMessageReceived(
    PrivateMessageReceivedEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    final currentState = state;

    final isCreator = event.message.creator == userId;
    final privateKey = await PrivateMessageKeyStorage().getPrivateKey();

    String clearContent =
        "Failed to find private key. Can't decrypt this message";

    if (event.message.creatorEncryptedSessionKey == 'NOT_ENCRYPTED' ||
        event.message.content.isEmpty) {
      clearContent = event.message.content;
    } else if (privateKey != null) {
      final aesKey = await decryptSymmetricKeyWithRsaPrivateKeyUsecase.call(
        encryptedAesKey: isCreator
            ? event.message.creatorEncryptedSessionKey
            : event.message.recipientEncryptedSessionKey,
        rsaPrivateKeyPem: privateKey,
      );
      clearContent = await decryptMessageUsingAesUsecase.call(
        encryptedContent: event.message.content,
        aesKey: aesKey,
      );
    }

    event.message.content = clearContent;

    Map<String, Map<String, PrivateMessage>> updatedDiscussions = {};

    if (currentState.messagesByDiscussion
        .containsKey(event.message.discussionId)) {
      final updatedDiscussion = Map<String, PrivateMessage>.from(
          currentState.messagesByDiscussion[event.message.discussionId]!)
        ..[event.message.id] = event.message;

      updatedDiscussions = Map<String, Map<String, PrivateMessage>>.from(
          currentState.messagesByDiscussion)
        ..[event.message.discussionId] = updatedDiscussion;
    } else {
      updatedDiscussions = Map<String, Map<String, PrivateMessage>>.from(
          currentState.messagesByDiscussion)
        ..[event.message.discussionId] = {
          event.message.id: event.message,
        };
    }

    emit(
      PrivateMessageState(
        discussionId: currentState.discussionId,
        messagesByDiscussion: updatedDiscussions,
        lastPrivateMessageReceivedEvent: event,
      ),
    );
  }

  Future<void> onAddNewMessage(
    AddNewMessageEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    final currentState = state;

    final aesEncryptResult = await encryptMessageUsingAesUsecase.call(
      content: event.content,
      aesKey: null,
    );
    final creatorEncryptedSessionKey =
        await encryptSymmetricKeyWithRsaPublicKeyUsecase.call(
      aesKey: aesEncryptResult.aesKey,
      rsaPublicKeyPem: event.creatorPublicKey,
    );
    final recipientEncryptedSessionKey =
        await encryptSymmetricKeyWithRsaPublicKeyUsecase.call(
      aesKey: aesEncryptResult.aesKey,
      rsaPublicKeyPem: event.recipientPublicKey,
    );

    final result = await createPrivateMessageUsecase.call(
      discussionId: event.discussionId,
      content: aesEncryptResult.encryptedContent,
      creatorEncryptedSessionKey: creatorEncryptedSessionKey,
      recipientEncryptedSessionKey: recipientEncryptedSessionKey,
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
            PrivateMessageState(
              discussionId: currentState.discussionId,
              messagesByDiscussion: currentState.messagesByDiscussion,
              message: ErrorMessage(error.messageKey),
              lastPrivateMessageReceivedEvent: null,
            ),
          );
        }
        return [];
      },
      (message) {},
    );

    // Don't do anything here, we will receive a message on the websocket and
    // update the state at this moment.
  }

  Future<void> onUpdateMessage(
    UpdateMessageEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    final currentState = state;

    final privateKey = await PrivateMessageKeyStorage().getPrivateKey();

    if (privateKey == null) {
      emit(
        PrivateMessageState(
          discussionId: currentState.discussionId,
          messagesByDiscussion: currentState.messagesByDiscussion,
          lastPrivateMessageReceivedEvent: null,
          message: ErrorMessage("faildToEncryptMessage"),
        ),
      );
    }

    final aesKey = await decryptSymmetricKeyWithRsaPrivateKeyUsecase.call(
      encryptedAesKey: event.creatorEncryptedSessionKey,
      rsaPrivateKeyPem: privateKey!,
    );

    final aesEncryptResult = await encryptMessageUsingAesUsecase.call(
      content: event.content,
      aesKey: SecretKey(base64.decode(aesKey)),
    );

    final result = await updatePrivateMessageUsecase.call(
      messageId: event.messageId,
      content: aesEncryptResult.encryptedContent,
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
            PrivateMessageState(
              discussionId: currentState.discussionId,
              messagesByDiscussion: currentState.messagesByDiscussion,
              lastPrivateMessageReceivedEvent: null,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
        return [];
      },
      (_) {},
    );

    // Don't do anything here, we will receive a message on the websocket and
    // update the state at this moment.
  }

  Future<void> onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    final currentState = state;

    final result = await deletePrivateMessageUsecase.call(
      messageId: event.messageId,
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
            PrivateMessageState(
              discussionId: currentState.discussionId,
              messagesByDiscussion: currentState.messagesByDiscussion,
              lastPrivateMessageReceivedEvent: null,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {},
    );

    // Don't do anything here, we will receive a message on the websocket and
    // update the state at this moment.
  }
}
