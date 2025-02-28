import 'dart:async';
import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cryptography/cryptography.dart';
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
import 'package:reallystick/features/private_messages/domain/usecases/mark_private_message_as_seen_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/update_private_message_usecase.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_states.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';

class PrivateMessageBloc
    extends Bloc<PrivateMessageEvent, PrivateMessageState> {
  final AuthBloc authBloc;
  final UserBloc userBloc;
  final ProfileBloc profileBloc;
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
  final MarkPrivateMessageAsSeenUsecase markPrivateMessageAsSeenUsecase =
      GetIt.instance<MarkPrivateMessageAsSeenUsecase>();
  final UpdatePrivateMessageUsecase updatePrivateMessageUsecase =
      GetIt.instance<UpdatePrivateMessageUsecase>();

  String? userId;

  PrivateMessageBloc({
    required this.authBloc,
    required this.userBloc,
    required this.profileBloc,
  }) : super(PrivateMessagesLoaded(
          discussionId: "",
          messagesByDiscussion: {},
          lastMessageReceived: null,
        )) {
    profileBlocSubscription = profileBloc.stream.listen((profileState) {
      if (profileState is ProfileAuthenticated) {
        userId = profileState.profile.id;
      }
    });

    on<InitializePrivateMessagesEvent>(initialize);
    on<PrivateMessageReceivedEvent>(onMessageReceived,
        transformer: sequential());
    on<AddNewMessageEvent>(onAddNewMessage);
    on<UpdateMessageEvent>(onUpdateMessage);
    on<DeleteMessageEvent>(onDeleteMessage);
    on<MarkPrivateMessageAsSeenEvent>(onMarkMessageAsSeen);
  }

  Future<void> initialize(
    InitializePrivateMessagesEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    final currentState = state as PrivateMessagesLoaded;
    emit(PrivateMessagesLoading());

    final result = await getPrivateMessagesOfDiscussionUsecase.call(
      discussionId: event.discussionId,
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
            PrivateMessagesLoaded(
              discussionId: currentState.discussionId,
              messagesByDiscussion: currentState.messagesByDiscussion,
              lastMessageReceived: null,
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

          if (privateKey != null) {
            final aesKey =
                await decryptSymmetricKeyWithRsaPrivateKeyUsecase.call(
              encryptedAesKey: isCreator
                  ? message.creatorEncryptedSessionKey
                  : message.recipientEncryptedSessionKey,
              rsaPrivateKeyPem: privateKey,
            );
            clearContent = await decryptMessageUsingAesUsecase.call(
                encryptedContent: message.content, aesKey: aesKey);
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
      ),
    );

    currentState.messagesByDiscussion[event.discussionId] = Map.fromEntries(
      messages.map(
        (m) => MapEntry(m.id, m),
      ),
    );

    emit(
      PrivateMessagesLoaded(
        discussionId: event.discussionId,
        messagesByDiscussion: currentState.messagesByDiscussion,
        lastMessageReceived: null,
      ),
    );
  }

  Future<void> onMessageReceived(
    PrivateMessageReceivedEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    if (state is! PrivateMessagesLoaded) {
      // Wait for a second and retry the event
      await Future.delayed(Duration(seconds: 1));
      add(event);
      return;
    }

    final currentState = state as PrivateMessagesLoaded;

    final isCreator = event.message.creator == userId;
    final privateKey = await PrivateMessageKeyStorage().getPrivateKey();

    String clearContent =
        "Failed to find private key. Can't decrypt this message";

    if (privateKey != null) {
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

    if (currentState.messagesByDiscussion
        .containsKey(event.message.discussionId)) {
      currentState.messagesByDiscussion[event.message.discussionId]![
          event.message.id] = event.message;
    } else {
      currentState.messagesByDiscussion[event.message.discussionId] = {
        event.message.id: event.message
      };
    }

    emit(
      PrivateMessagesLoaded(
        discussionId: currentState.discussionId,
        messagesByDiscussion: currentState.messagesByDiscussion,
        lastMessageReceived: event.message,
      ),
    );
  }

  Future<void> onAddNewMessage(
    AddNewMessageEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    final currentState = state as PrivateMessagesLoaded;

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
            PrivateMessagesLoaded(
              discussionId: currentState.discussionId,
              messagesByDiscussion: currentState.messagesByDiscussion,
              message: ErrorMessage(error.messageKey),
              lastMessageReceived: null,
            ),
          );
        }
        return [];
      },
      (message) {
        message.content = event.content;

        if (currentState.messagesByDiscussion
            .containsKey(message.discussionId)) {
          currentState.messagesByDiscussion[message.discussionId]![message.id] =
              message;
        } else {
          currentState.messagesByDiscussion[message.discussionId] = {
            message.id: message
          };
        }

        emit(
          PrivateMessagesLoaded(
            discussionId: currentState.discussionId,
            messagesByDiscussion: currentState.messagesByDiscussion,
            lastMessageReceived: message,
          ),
        );
      },
    );
  }

  Future<void> onUpdateMessage(
    UpdateMessageEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    final currentState = state as PrivateMessagesLoaded;
    emit(PrivateMessagesLoading());

    final privateKey = await PrivateMessageKeyStorage().getPrivateKey();

    if (privateKey == null) {
      emit(
        PrivateMessagesLoaded(
          discussionId: currentState.discussionId,
          messagesByDiscussion: currentState.messagesByDiscussion,
          lastMessageReceived: null,
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
            PrivateMessagesLoaded(
              discussionId: currentState.discussionId,
              messagesByDiscussion: currentState.messagesByDiscussion,
              lastMessageReceived: null,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
        return [];
      },
      (message) {
        message.content = event.content;

        if (currentState.messagesByDiscussion
            .containsKey(message.discussionId)) {
          currentState.messagesByDiscussion[message.discussionId]![message.id] =
              message;
        } else {
          currentState.messagesByDiscussion[message.discussionId] = {
            message.id: message
          };
        }

        emit(
          PrivateMessagesLoaded(
            discussionId: currentState.discussionId,
            messagesByDiscussion: currentState.messagesByDiscussion,
            lastMessageReceived: message,
          ),
        );
      },
    );
  }

  Future<void> onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    final currentState = state as PrivateMessagesLoaded;
    emit(PrivateMessagesLoading());

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
            PrivateMessagesLoaded(
              discussionId: currentState.discussionId,
              messagesByDiscussion: currentState.messagesByDiscussion,
              lastMessageReceived: null,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        if (currentState.messagesByDiscussion.containsKey(event.discussionId)) {
          if (currentState.messagesByDiscussion[event.discussionId]!
              .containsKey(event.messageId)) {
            currentState
                .messagesByDiscussion[event.discussionId]![event.messageId]!
                .deleted = true;
          }
        }
      },
    );

    PrivateMessage? lastMessage =
        currentState.messagesByDiscussion[event.discussionId] != null
            ? currentState
                .messagesByDiscussion[event.discussionId]![event.messageId]
            : null;

    emit(
      PrivateMessagesLoaded(
        discussionId: currentState.discussionId,
        messagesByDiscussion: currentState.messagesByDiscussion,
        lastMessageReceived: lastMessage,
      ),
    );
  }

  Future<void> onMarkMessageAsSeen(
    MarkPrivateMessageAsSeenEvent event,
    Emitter<PrivateMessageState> emit,
  ) async {
    final currentState = state as PrivateMessagesLoaded;
    emit(PrivateMessagesLoading());

    final result = await markPrivateMessageAsSeenUsecase.call(
      privateMessageId: event.messageId,
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
            PrivateMessagesLoaded(
              discussionId: currentState.discussionId,
              messagesByDiscussion: currentState.messagesByDiscussion,
              message: ErrorMessage(error.messageKey),
              lastMessageReceived: null,
            ),
          );
        }
      },
      (_) {
        if (currentState.messagesByDiscussion.containsKey(event.discussionId)) {
          if (currentState.messagesByDiscussion[event.discussionId]!
              .containsKey(event.messageId)) {
            currentState
                .messagesByDiscussion[event.discussionId]![event.messageId]!
                .seen = true;
          }
        }
      },
    );

    PrivateMessage? lastMessage =
        currentState.messagesByDiscussion[event.discussionId] != null
            ? currentState
                .messagesByDiscussion[event.discussionId]![event.messageId]
            : null;

    emit(
      PrivateMessagesLoaded(
        discussionId: currentState.discussionId,
        messagesByDiscussion: currentState.messagesByDiscussion,
        lastMessageReceived: lastMessage,
      ),
    );
  }
}
